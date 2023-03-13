# frozen_string_literal: true

require "kanal/core/plugins/plugin"

module Kanal
  module Plugins
    # This module stores needed classes and helpers for batteries plugin
    module Batteries
      # Plugin with some batteries like .body property etc
      class BatteriesPlugin < Core::Plugins::Plugin
        def name
          :batteries
        end

        def setup(core)
          source_batteries core
          body_batteries core
          flow_batteries core
          attachments_batteries core
          reply_markup_batteries core
        end

        def flow_batteries(core)
          core.add_condition_pack :flow do
            add_condition :any do
              met? do |_, _, _|
                true
              end
            end
          end
        end

        def source_batteries(core)
          # This parameter can be filled by different plugins/interfaces
          # to point from which source message came
          core.register_input_parameter :source

          core.add_condition_pack :source do
            add_condition :from do
              with_argument

              met? do |input, _, argument|
                input.source == argument
              end
            end
          end
        end

        def body_batteries(core)
          core.register_input_parameter :body
          core.register_output_parameter :body

          core.add_condition_pack :body do
            add_condition :starts_with do
              with_argument

              met? do |input, _, argument|
                if input.body.is_a? String
                  input.body.start_with? argument
                else
                  false
                end
              end
            end

            add_condition :ends_with do
              with_argument

              met? do |input, _, argument|
                if input.body.is_a? String
                  input.body.end_with? argument
                else
                  false
                end
              end
            end

            add_condition :contains do
              with_argument

              met? do |input, _, argument|
                if input.body.is_a? String
                  input.body.include? argument
                else
                  false
                end
              end
            end

            add_condition :contains_one_of do
              with_argument

              met? do |input, _, argument|
                met = false

                argument.each do |word|
                  met = input.body.include? word

                  break if met
                end

                met
              end
            end

            add_condition :equals do
              with_argument

              met? do |input, _, argument|
                input.body == argument
              end
            end
          end
        end

        def attachments_batteries(core)
          core.register_input_parameter :image_url
          core.register_input_parameter :audio_url
          core.register_input_parameter :file_url

          core.register_output_parameter :image
          core.register_output_parameter :audio
          core.register_output_parameter :file
        end

        def reply_markup_batteries(core)
          core.register_output_parameter :reply_markup
        end
      end
    end
  end
end
