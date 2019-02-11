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

package EnsEMBL::Web::Form::ViewConfigRegMatrix;

use strict;
use warnings;

use parent qw(EnsEMBL::Web::Form::ViewConfigMatrixForm);

sub configuration_content {
  my ($self, $dimX, $dimY) = @_;

  return qq(      
      <div class="track-panel track-configuration" id="configuration-content">
        <div class="vertical-sub-header">$dimX</div>
        <div class="configuration-legend">
          <div class="config-key"><span class="track-key on"></span>Data track on</div>
          <div class="config-key"><span class="track-key off"></span>Data track off</div>
          <div class="config-key"><span class="track-key no-data"></span>No data</div>
          <div class="config-key"><span class="track-key peak"><img src="/i/render/peak_blue50.svg" /></span>Peaks</div>
          <div class="config-key"><span class="track-key signal"><img src="/i/render/signal_blue50.svg" /></span>Signal</div>
        </div>
        <div class="horizontal-sub-header">$dimY</div>
        <button class="fade-button reset-button _matrix">Reset</button>
        <div class="track-popup column-cell">
          <ul>
            <li>
              <label class="switch"><input type="checkbox" name="column-switch"><span class="slider round"></span><span class="switch-label">Column</span></label>
            </li>
          </ul>
          <ul>
            <li>
              <label class="switch"><input type="checkbox" name="cell-switch"><span class="slider round"></span><span class="switch-label">Cell</span></label>
            </li>
          </ul>
        </div>
        <div class="track-popup peak-signal">
          <ul>
            <li>
              <label class="switch"><input type="checkbox" name="column-switch"><span class="slider round"></span><span class="switch-label">Column</span></label><input type='radio' name="column-radio" class="_peak-signal" /><text>Peaks & signal</text>  
            </li>
            <li><input type='radio' name="column-radio" class="_peak"/><text>Peaks</text></li>
            <li><input type='radio' name="column-radio" class="_signal"/><text>Signal</text></li>
          </ul>
          <ul>
            <li>
              <label class="switch"><input type="checkbox" name="row-switch"><span class="slider round"></span><span class="switch-label">Row</span></label><input type='radio' name="row-radio" class="_peak-signal"/><text>Peaks & signal</text>
            </li>
            <li>
              <input type='radio' name="row-radio" class="_peak"/><text>Peaks</text>
            </li>
            <li>
              <input type='radio' name="row-radio" class="_signal"/><text>Signal</text>
            </li>
          </ul>
          <ul>
            <li>
              <label class="switch"><input type="checkbox" name="cell-switch"><span class="slider round"></span><span class="switch-label">Cell</span></label><input type='radio' name="cell-radio" class="_peak-signal"/><text>Peaks & signal</text>
            </li>
            <li>
              <input type='radio' name="cell-radio" class="_peak"/><text>Peaks</text>
            </li>
            <li>
              <input type='radio' name="cell-radio" class="_signal"/><text>Signal</text>
            </li>
          </ul>
        </div>
        <div class="hidebox"></div>
        <div class="matrix-container">
        </div>        
      </div>

      <div class="result-box">
        <h4>Selected tracks</h4>

        <div class="filter-content">
          <h5 class="result-header">$dimX <span class="error _dx">Please select $dimX</span></h5>
          <div class="result-content" id="dx">
            <div class="sub-result-link">$dimX</div>
            <div class="count-container"><span class="current-count">0</span> / <span class="total"></span> available</div>
            <div class="_show show-hide hidden">Show selected</div><div class="_hide show-hide hidden">Hide selected</div>
            <ul class="result-list hidden">
              <span class="hidden lhsection-id">dx-content</span>
            </ul>
          </div>

          <h5 class="result-header">$dimY</h5>
          <div id="dy">
            <div class="result-content" id="Histone">
              <span class="_parent-tab-id hidden">dy-tab</span>
              <div class="sub-result-link">Histone</div>
              <div class="count-container"><span class="current-count">0</span> / <span class="total"></span> available</div>
              <div class="_show show-hide hidden">Show selected</div><div class="_hide show-hide hidden">Hide selected</div>
              <ul class="result-list hidden">
                <span class="hidden lhsection-id">Histone-content</span>
              </ul>
            </div>
            <div class="result-content" id="Open_Chromatin">
							<span class="_parent-tab-id hidden">dy-tab</span>
              <div class="sub-result-link">Open chromatin</div>
              <div class="count-container"><span class="current-count">0</span> / <span class="total"></span> available</div>
              <div class="_show show-hide hidden">Show selected</div><div class="_hide show-hide hidden">Hide selected</div>
              <ul class="result-list hidden">
                <span class="hidden lhsection-id">Open_Chromatin-content</span>
              </ul>
            </div>
            <div class="result-content" id="Transcription_factors">
							<span class="_parent-tab-id hidden">dy-tab</span>
              <div class="sub-result-link">Transcription factors</div>
              <div class="count-container"><span class="current-count">0</span> / <span class="total"></span> available</div>
              <div class="_show show-hide hidden">Show selected</div><div class="_hide show-hide hidden">Hide selected</div>
              <ul class="result-list hidden">
                <span class="hidden lhsection-id">transcription_factors-content</span>
              </ul>
            </div>          
          </div>

          <h5 class="result-header">Source <span class="error _source hidden">Please select Source</span></h5>
          <div class="result-content" id="source">
            <ul class="result-list no-left-margin">
              <span class="hidden lhsection-id">source-content</span>
              <li class="noremove">
                <span class="fancy-checkbox selected"></span><text>Blueprint</text>
              </li>
              <li class="noremove">
                <span class="fancy-checkbox selected"></span><text>Another source</text>
              </li>
            </ul>
          </div>
        </div>
  );
}

1;
