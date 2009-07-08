package EnsEMBL::Web::Text::FeatureParser::ID;

=head1 NAME

EnsEMBL::Web::Text::FeatureParser::ID;

=head1 SYNOPSIS

This object parses Gene/Transcript/Protein ID data supplied by the user for use by other Ensembl objects

=head1 DESCRIPTION

    my $parser = EnsEMBL::Web::Text::FeatureParser->new();
    $parser->init($data);
    $parser->parse($data);

=head1 LICENCE

This code is distributed under an Apache style licence:
Please see http://www.ensembl.org/code_licence.html for details

=head1 CONTACT

=cut

use strict;
use warnings;
use EnsEMBL::Web::Text::FeatureParser;
use EnsEMBL::Web::Text::Feature::ID;
use Data::Dumper;

our @ISA = qw(EnsEMBL::Web::Text::FeatureParser);

#----------------------------------------------------------------------

=head2 parse_row

    Arg [1]   :
    Function  : Parses an individual row of data, i.e. a single feature
    Returntype:
    Exceptions:
    Caller    :
    Example   :

=cut

sub parse_row { 
  my( $self, $row, $format ) = @_;  
  return if ($row =~ /^\#/);  
  $row =~ s/[\t\r\s]+$//g; 
  if( $row =~ /^browser\s+(\w+)\s+(.*)/i ) {
    $self->{'browser_switches'}{$1}=$2;
  }   elsif ($row =~ s/^track\s+(.*)$/$1/i) {
  my %config;
  while( $row ne '' ) {
    if( $row =~ s/^(\w+)\s*=\s*\"([^\"]+)\"// ) {
      my $key   = $1; 
      my $value = $2;
      while( $value =~ s/\\$// && $row ne '') {
        if( $row =~ s/^([^\"]+)\"\s*// ) {
          $value .= "\"$1";
        } else {
          $value .= "\"$row";
          $row = '';
        }
      }
      $row =~ s/^\s*//;
      $config{$key} = $value;
    } elsif( $row =~ s/(\w+)\s*=\s*(\S+)\s*// ) {
      $config{$1} = $2;
    } else {
      $row ='';
    }
  } 
  my $current_key = $config{'name'} || 'default';
    $self->{'tracks'}{ $current_key } = { 'features' => [], 'config' => \%config };
    $self->{'_current_key'} = $current_key;
  } else {  
    return unless $row =~ /\w+/g ;
    my @ws_delimited = split /\s+/, $row;
    my $current_key = $self->{'_current_key'} ;
# use Data::Dumper; warn Dumper \@ws_delimited;
# $current_key = $ws_delimited[3] if $current_key eq 'default';
    $self->store_feature( $current_key, EnsEMBL::Web::Text::Feature::ID->new( \@ws_delimited ) ) if
    $self->filter($ws_delimited[0]);
  }

}

1;
