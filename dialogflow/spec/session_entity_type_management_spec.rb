# Copyright 2018 Google, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "rspec"
require "google/cloud/dialogflow"
require "spec_helper"

require_relative "../session_entity_type_management"
require_relative "../detect_intent_texts"
require_relative "../entity_type_management"

describe "Session Entity Type Management" do

  before do
    @project_id = ENV["GOOGLE_CLOUD_PROJECT"]
    @session_id = "fake_session_for_testing"
    @entity_type_display_name = "fake_display_name_for_testing_session_entity_types"
    @entity_values = ["fake_entity_value_1", "fake_entity_value_2"]
  end

  example "create session_entity_type" do
    hide do
      # clean up entity type
      entity_type_ids = get_entity_type_ids project_id: @project_id,
                                            display_name: @entity_type_display_name
      entity_type_ids.each do |entity_type_id|
        delete_entity_type project_id: @project_id,
                           entity_type_id: entity_type_id
      end
      # create an entity type to be overridden
      create_entity_type project_id: @project_id,
                         display_name: @entity_type_display_name,
                         kind: :KIND_MAP

      # create a session
      detect_intent_texts project_id:    @project_id,
                          session_id:    @session_id,
                          texts:         ["hi"],
                          language_code: "en-US"

      create_session_entity_type project_id: @project_id,
                                 session_id: @session_id,
                                 entity_type_display_name: @entity_type_display_name,
                                 entity_values: @entity_values
    end
    expectation = expect {
      list_session_entity_types project_id: @project_id, session_id: @session_id
    }

    expectation.to output(/#{@session_id}/).to_stdout
    expectation.to output(/#{@entity_type_display_name}/).to_stdout
    expectation.to output(/#{@entity_values[0]}/).to_stdout
    expectation.to output(/#{@entity_values[1]}/).to_stdout
  end

  example "delete session_entity_type" do
    hide do
      delete_session_entity_type project_id: @project_id,
                     session_id: @session_id,
                     entity_type_display_name: @entity_type_display_name
    end
    expectation = expect {
      list_session_entity_types project_id: @project_id, session_id: @session_id
    }

    expectation.not_to output(/#{@entity_type_display_name}/).to_stdout
    expectation.not_to output(/#{@entity_values[0]}/).to_stdout
    expectation.not_to output(/#{@entity_values[1]}/).to_stdout

    hide do
      # clean up entity type
      entity_type_ids = get_entity_type_ids project_id: @project_id,
                                            display_name: @entity_type_display_name
      entity_type_ids.each do |entity_type_id|
        delete_entity_type project_id: @project_id,
                           entity_type_id: entity_type_id
      end
    end
  end
end
