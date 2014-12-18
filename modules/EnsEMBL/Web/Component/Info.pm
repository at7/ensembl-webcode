=head1 LICENSE

Copyright [1999-2014] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute

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

package EnsEMBL::Web::Component::Info;

use strict;

use base qw(EnsEMBL::Web::Component);

sub format_gallery {
  my ($self, @previews) = @_;
  my ($html, @toc);

  foreach my $group (@previews) {
    my @pages = @{$group->{'pages'}||[]};
    #next unless scalar @pages;

    my $title = $group->{'title'};
    push @toc, sprintf('<a href="#%s">%s</a>', lc($title), $title);
    $html .= sprintf('<h2 id="%s">%s</h2>', lc($title), $title);

    $html .= '<div class="gallery">';

    foreach my $page (@pages) {
      $html .= '<div class="gallery_preview">';

      $html .= sprintf('<a href="%s"><img src="/i/gallery/%s.png" /></a><br /><div class="preview_caption"><a href="%s" class="nodeco">%s</a></div>', $page->{'url'}, $page->{'img'}, $page->{'url'}, $page->{'caption'});

      $html .= '</div>';
    }


    $html .= '</div>';
  }
  my $toc_string = sprintf('<p class="center">%s</p>', join(' | ', @toc));

  return $toc_string.$html;  
}

1;
