# frozen_string_literal: true

module Ci
  # This model represents metadata for a running build.
  class RunningBuild < Ci::ApplicationRecord
    include Ci::Partitionable

    partitionable scope: :build

    belongs_to :project
    belongs_to :build, # rubocop: disable Rails/InverseOf -- this relation is not present on build
      ->(running_build) { in_partition(running_build) },
      class_name: 'Ci::Build',
      partition_foreign_key: :partition_id
    belongs_to :runner, class_name: 'Ci::Runner'

    enum runner_type: ::Ci::Runner.runner_types

    def self.upsert_build!(build)
      if build.runner.nil?
        raise ArgumentError, 'build has not been picked by a runner'
      end

      entry = self.new(
        build: build,
        project: build.project,
        runner: build.runner,
        runner_type: build.runner.runner_type
      )

      entry.validate!

      self.upsert(entry.attributes.compact, returning: %w[build_id], unique_by: :build_id)
    end
  end
end
