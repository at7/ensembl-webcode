=head1 LICENSE

Copyright [1999-2015] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute

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

package EnsEMBL::Web::Apache::SSI;

use strict;
use warnings;

use Apache2::Const qw(:common :methods :http);

use EnsEMBL::Web::Controller::Doxygen;
use EnsEMBL::Web::Controller::SSI;

sub get_controller {
  ## Gets the controller class name that should server the given file
  ## @param Absolute path of the file to be served
  ## @return Package name of the required controller
  my $filename = shift;
  return $filename =~ /\/Doxygen\// ? 'EnsEMBL::Web::Controller::Doxygen' : 'EnsEMBL::Web::Controller::SSI';
}

sub handler {
  ## Actual handler called by EnsEMBL::Web::Apache::Handlers for .html files (optionally with 'server side includes')
  ## @param Apache2::RequestRec request object
  ## @param SpeciesDefs object
  ## @return One of the Apache2::Const constants or undef in case this handler can not handle this request
  my ($r, $species_defs) = @_;

  # if client is just messing around
  my $method_number = $r->method_number;
  my $method_error;
  if ($method_number == M_OPTIONS) {
    $method_error = DECLINED;
  } elsif ($method_number == M_INVALID) {
    $method_error = HTTP_NOT_IMPLEMENTED;
  } elsif ($method_number != M_GET) {
    $method_error = HTTP_METHOD_NOT_ALLOWED;
  }

  # leave a warning in the logs and return error code
  if (defined $method_error) {
    $r->log->error('Invalid method in request ', $r->the_request);
    return $method_error;
  }

  # get filename as parsed and validated by parent handler
  my $filename = $r->subprocess_env('ENSEMBL_FILENAME');

  # get appropriate controller to serve this request
  my $controller = get_controller($filename)->new($r, $species_defs, {'filename' => $filename});

  $controller->process;

  return $controller->status;
}

1;
