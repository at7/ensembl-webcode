package EnsEMBL::Web::Component::Variation::Summary;

use strict;
use warnings;
no warnings "uninitialized";
use base qw(EnsEMBL::Web::Component::Variation);
use CGI qw(escapeHTML);

sub _init {
  my $self = shift;
  $self->cacheable( 0 );
  $self->ajaxable(  1 );
}

sub content {
  return '';
}

1;
