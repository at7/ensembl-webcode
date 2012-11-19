package EnsEMBL::Web::Tools::Registry;

use strict;
use base qw(EnsEMBL::Web::Root);

use Bio::EnsEMBL::Registry;

sub new {
  my ($class, $conf) = @_;
  my $self = { 'conf' => $conf };
  bless $self, $class;
  return $self;
}

sub configure {
  ### Loads the adaptor into the registry from the self->{'conf'} definitions
  ### Returns: none
  my $self = shift;

  my %adaptors = (
    VARIATION           => 'Bio::EnsEMBL::Variation::DBSQL::DBAdaptor',
    FUNCGEN             => 'Bio::EnsEMBL::Funcgen::DBSQL::DBAdaptor',
    OTHERFEATURES       => 'Bio::EnsEMBL::DBSQL::DBAdaptor',
    RNASEQ              => 'Bio::EnsEMBL::DBSQL::DBAdaptor',
    CDNA                => 'Bio::EnsEMBL::DBSQL::DBAdaptor',
    VEGA                => 'Bio::EnsEMBL::DBSQL::DBAdaptor',
    VEGA_ENSEMBL        => 'Bio::EnsEMBL::DBSQL::DBAdaptor',
    VEGA_UPDATE         => 'Bio::EnsEMBL::DBSQL::DBAdaptor',
    CORE                => 'Bio::EnsEMBL::DBSQL::DBAdaptor',
    COMPARA             => 'Bio::EnsEMBL::Compara::DBSQL::DBAdaptor',
    COMPARA_PAN_ENSEMBL => 'Bio::EnsEMBL::Compara::DBSQL::DBAdaptor',
    USERDATA            => 'Bio::EnsEMBL::DBSQL::DBAdaptor',
    COMPARA_MULTIPLE    => undef,
    WEBSITE             => undef,
    HEALTHCHECK         => undef,
    BLAST               => undef,
    BLAST_LOG           => undef,
    MART                => undef,
    GO                  => undef,
    FASTA               => undef,
    WEB_COMMON          => undef,
    PRODUCTION          => undef,
  );

  for my $species (keys %{$self->{'conf'}->{'_storage'}}, 'MULTI') {
    (my $sp = $species) =~ s/_/ /g;
    $sp = 'ancestral_sequences' if $sp eq 'MULTI';
    
    next unless ref $self->{'conf'}->{'_storage'}{$species};
    
    Bio::EnsEMBL::Registry->add_alias($species, $sp);
    
    for my $type (keys %{$self->{'conf'}->{'_storage'}{$species}{'databases'}}){
      ## Grab the configuration information from the SpeciesDefs object
      my $TEMP = $self->{'conf'}->{'_storage'}{$species}{'databases'}{$type};
     
      ## Skip if the name hasn't been set (mis-configured database)
      if ($sp ne 'ancestral_sequences') {
        warn((' ' x 10) . "[WARN] no NAME for $sp $type") unless $TEMP->{'NAME'};
        warn((' ' x 10) . "[WARN] no USER for $sp $type") unless $TEMP->{'USER'};
      }
      
      next unless $TEMP->{'NAME'} && $TEMP->{'USER'};

      my $is_collection = $self->{'conf'}->{'_storage'}{$species}{'SPP_IN_DB'} > 1 ? 1 : 0;
 
      my %arg = ( '-species' => $species, '-dbname' => $TEMP->{'NAME'}, '-species_id' =>  $self->{'conf'}->{'_storage'}{$species}->{SPECIES_META_ID} || 1, '-multispecies_db' => $is_collection );
      
      ## Copy through the other parameters if defined
      foreach (qw(host pass port user driver)) {
        $arg{"-$_"} = $TEMP->{uc $_} if defined $TEMP->{uc $_};
      }
      
      ## Check to see if the adaptor is in the known list above
      if ($type =~ /DATABASE_(\w+)/ && exists $adaptors{$1}) {
        ## If the value is defined then we will create the adaptor here
        if (my $module = $adaptors{$1}) {
          ## Create a new "module" object. Stores info - but doesn't create connection yet
          $module->new(%arg, '-group' => lc $1) if $self->dynamic_use($module);
        }
      } else {
        warn "unknown database type $type\n";
      }
    }
  }
  
  Bio::EnsEMBL::Registry->load_all($SiteDefs::ENSEMBL_REGISTRY);
  Bio::EnsEMBL::Registry->no_version_check(1) if $SiteDefs::ENSEMBL_NOVERSIONCHECK;
}

1;
