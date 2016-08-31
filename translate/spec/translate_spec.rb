# Copyright 2016 Google, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in write, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require_relative "../samples"
require "rspec"

RSpec.describe "Google Translate API samples" do

  before do
    @api_key = ENV["TRANSLATE_KEY"]
  end

  # Capture and return STDOUT output by block
  def capture &block
    real_stdout = $stdout
    $stdout = StringIO.new
    block.call
    @captured_output = $stdout.string
  ensure
    $stdout = real_stdout
  end
  attr_reader :captured_output

  example "translate text" do
    capture do
      translate_text api_key:       @api_key,
                     language_code: "fr",
                     text:          "Alice and Bob are kind"
    end

    expect(captured_output).to include "Original language: en translated to: fr"
    expect(captured_output).to include(
      %{Translated 'Alice and Bob are kind' to '"Alice et Bob sont gentils"'}
    )
  end

  example "detect language" do
    expect {
      detect_language api_key: @api_key, text: "Sample text written in English"
    }.to output(
      /'Sample text written in English' detected as language: en/
    ).to_stdout
  end

  example "list supported language codes" do
    capture { list_supported_language_codes api_key: @api_key }

    # Check for a few supported language codes (first sorted alphabetically)
    expect(captured_output).to include "af"
    expect(captured_output).to include "am"
    expect(captured_output).to include "ar"
    expect(captured_output).to include "az"
    expect(captured_output).to include "be"
  end

  example "list supported language names" do
    capture do
      list_supported_language_names api_key: @api_key, language_code: "en"
    end

    # Check for a few supported language codes (first sorted alphabetically)
    expect(captured_output).to include "af Afrikaans"
    expect(captured_output).to include "am Amharic"
    expect(captured_output).to include "ar Arabic"
    expect(captured_output).to include "az Azerbaijani"
    expect(captured_output).to include "be Belarusian"
  end
end
