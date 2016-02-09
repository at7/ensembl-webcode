=head1 LICENSE

Copyright [1999-2016] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=cut

package EnsEMBL::Web::Component::Variation::PairwiseLD;

use strict;
use HTML::Entities qw(encode_entities);

use base qw(EnsEMBL::Web::Component::Variation);

sub _init {
  my $self = shift;
  $self->cacheable(0);
  $self->ajaxable(1);
}

sub content {
  my $self = shift;
  my $object = $self->object;
  my $variant = $object->Obj;
  my $variant_name = $variant->name;

  my $hub    = $self->hub;
  
  return $self->_info('A unique location can not be determined for this Variation', $object->not_unique_location) if $object->not_unique_location;  

  my $url = $self->ajax_url('results', { first_variant_name => undef, second_variant_name => undef });  
  my $id  = $self->id;  
  my $second_variant_name = '';
  return sprintf('
    <h2>Pairwise linkage disequilibrium</h2>
    <div class="navbar print_hide" style="padding-left:5px">
      <input type="hidden" class="panel_type" value="Content" />
      <form class="update_panel" action="#">
        <label for="variant">First variant: %s</label><br>
        <label for="variant">Enter the name for the second variant:</label>
        <input type="text" name="second_variant_name" id="variant" value="%s" size="30"/>
        <input type="hidden" name="first_variant_name" value="%s" />
        <input type="hidden" name="panel_id" value="%s" />
        <input type="hidden" name="url" value="%s" />
        <input type="hidden" name="element" value=".results" />
        <input class="fbutton" type="submit" value="Compute" />
        <small>(e.g. rs678)</small>
      </form>
    </div>
    <div class="results">%s</div>
  ', $variant_name, $second_variant_name, $variant_name, $id, $url, $self->content_results);

}


sub format_parent {
  my ($self, $parent_data) = @_;
  return ($parent_data && $parent_data->{'Name'}) ? $parent_data->{'Name'} : '-';
}


sub get_table_headings {
  return [
    { key => 'Sample',      title => 'Sample<br /><small>(Male/Female/Unknown)</small>',     sort => 'html', width => '20%', help => 'Sample name and gender'         },
    { key => 'Genotype',    title => 'Genotype<br /><small>(forward strand)</small>',        sort => 'html', width => '15%', help => 'Genotype on the forward strand' },
    { key => 'Description', title => 'Description',                                          sort => 'html'                                                           },
    { key => 'Population',  title => 'Population(s)',                                        sort => 'html'                                                           },
    { key => 'Father',      title => 'Father',                                               sort => 'none'                                                           },
    { key => 'Mother',      title => 'Mother',                                               sort => 'none'                                                           }
  ];
}


sub content_results {
  my $self         = shift;
  my $object       = $self->object;
  my $variant      = $object->Obj;
  my $hub          = $self->hub;
  my $species_defs = $hub->species_defs;

  my $first_variant_name  = $hub->param('first_variant_name');
  my $second_variant_name = $hub->param('second_variant_name');

  return unless $second_variant_name;
  $second_variant_name =~ s/^\W+//;
  $second_variant_name =~ s/\s+$//;

  # set path information for LD calculations
  $Bio::EnsEMBL::Variation::DBSQL::LDFeatureContainerAdaptor::BINARY_FILE = $species_defs->ENSEMBL_CALC_GENOTYPES_FILE;
  $Bio::EnsEMBL::Variation::DBSQL::LDFeatureContainerAdaptor::TMP_PATH = $species_defs->ENSEMBL_TMP_TMP;

  my $ldfca = $variant->adaptor->db->get_LDFeatureContainerAdaptor;
  my $va = $variant->adaptor->db->get_VariationAdaptor;
  my $second_variant = $va->fetch_by_name($second_variant_name);

  if (!$second_variant) {
    return qq{<div>Could not fetch variant object for variant $second_variant_name</div>};
  }

  my $source = $variant->source_name;
  my $max_distance = $hub->param('max_distance') || 50000;
  my $min_r2 = defined $hub->param('min_r2') ? $hub->param('min_r2') : 0.8;
  my $min_d_prime = defined $hub->param('min_d_prime') ? $hub->param('min_d_prime') : 0.8;
  my $min_p_log = $hub->param('min_p_log');
  my $only_phenotypes = $hub->param('only_phenotypes') eq 'yes';
  my %mappings = %{$object->variation_feature_mapping}; # determine correct SNP location
  my ($vf, $loc);

  if (keys %mappings == 1) {
    ($loc) = values %mappings; 
  } else {
    $loc = $mappings{$hub->param('vf')};
  }
  # get the VF that matches the selected location
  foreach (@{$object->get_variation_features}) {
    if ($_->seq_region_start == $loc->{'start'}) {
      $vf = $_;
      last;
    }
  }

  my $vfs = $second_variant->get_all_VariationFeatures;

  my @ld_values = @{$ldfca->fetch_by_VariationFeatures([$vf, $vfs->[0]])->get_all_ld_values(1)};  
  my $return_html = '';  
  foreach my $hash (@ld_values) {
    my $variation1 = $hash->{variation_name1};
    my $variation2 = $hash->{variation_name2};
    my $r2 = $hash->{r2};
    my $d_prime = $hash->{d_prime};
    my $population_id = $hash->{population_id};
    $return_html = $return_html . "<div>$variation1 $variation2 $r2 $d_prime $population_id</div><br>";
  } 
 

#  return qq{<div>$first_variant_name<br>$second_variant_name<br>$flat_ld_values<br>@ld_values</div>};

  return $return_html;


=begin

  my $sample = $hub->param('sample');
  
  return unless defined $sample;
  
  $sample =~ s/^\W+//;
  $sample =~ s/\s+$//;
  
  my %rows;
  my $flag_children = 0;
  my $html;
  my %sample_data;
   
  my $sample_gt_objs = $object->sample_genotypes_obj;
    
  # Selects the sample genotypes where their sample names match the searched name
  my @matching_sample_gt_objs = (length($sample) > 1 ) ? grep { $_->sample->name =~ /$sample/i } @$sample_gt_objs : ();
    
  if (scalar (@matching_sample_gt_objs)) {
    my %sample_data;
    my $rows;
    my $al_colours = $self->object->get_allele_genotype_colours;    

    # Retrieve sample & sample genotype information
    foreach my $sample_gt_obj (@matching_sample_gt_objs) {
    
      my $genotype = $object->sample_genotype($sample_gt_obj);
      next if $genotype eq '(indeterminate)';
        $genotype =~ s/$al/$al_colours->{$al}/g;
      }
      
      my $sample_obj = $sample_gt_obj->sample;
      my $sample_id  = $sample_obj->dbID;
     
      my $sample_name  = $sample_obj->name;
      my $sample_label = $sample_name;
      if ($sample_label =~ /(1000\s*genomes|hapmap)/i) {
        my @composed_name = split(':', $sample_label);
        $sample_label = $composed_name[$#composed_name];
      }

      my $gender        = $sample_obj->individual->gender;
      my $description   = $object->description($sample_obj);
         $description ||= '-';
      my $population    = $self->get_all_populations($sample_obj);  
         
      my %parents;
      foreach my $parent ('father','mother') {
         my $parent_data   = $object->parent($sample_obj->individual, $parent);
         $parents{$parent} = $self->format_parent($parent_data);
      }         
    
      # Format the content of each cell of the line
      my $row = {
        Sample      => sprintf("<small id=\"%s\">%s (%s)</small>", $sample_name, $sample_label, substr($gender, 0, 1)),
        Genotype    => "<small>$genotype</small>",
        Description => "<small>$description</small>",
        Population  => "<small>$population</small>",
        Father      => "<small>$parents{father}</small>",
        Mother      => "<small>$parents{mother}</small>",
        Children    => '-'
      };
    
      # Children
      my $children      = $object->child($sample_obj->individual);
      my @children_list = map { sprintf "<small>$_ (%s)</small>", substr($children->{$_}[0], 0, 1) } keys %{$children};
    
      if (@children_list) {
        $row->{'Children'} = join ', ', @children_list;
        $flag_children = 1;
      }
        
      push @$rows, $row;
    }

    my $columns = $self->get_table_headings;
    push @$columns, { key => 'Children', title => 'Children<br /><small>(Male/Female)</small>', sort => 'none', help => 'Children names and genders' } if $flag_children;
    
    my $sample_table = $self->new_table($columns, $rows, { data_table => 1, download_table => 1, sorting => [ 'Sample asc' ], data_table_config => {iDisplayLength => 25} });
    $html .= '<div style="margin:0px 0px 50px;padding:0px"><h2>Results for "'.$sample.'" ('.scalar @$rows.')</h2>'.$sample_table->render.'</div>';

  } else {
    $html .= $self->warning_message($sample);
  }

  return qq{<div class="js_panel">$html</div>};
=end
=cut
}


sub get_all_populations {
  my $self   = shift;
  my $sample = shift;

  my @pop_names = map { $_->name } @{$sample->get_all_Populations };
  
  return (scalar @pop_names > 0) ? join('; ',sort(@pop_names)) : '-';
}

sub warning_message {
  my $self   = shift;
  my $sample = shift;
  
  return $self->_warning('Not found', qq{No genotype associated with this variant was found for the sample name '<b>$sample</b>'!});
}



1;
