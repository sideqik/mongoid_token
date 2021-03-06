require 'mongoid/token/collisions'

module Mongoid
  module Token
    class CollisionResolver
      attr_accessor :create_new_token
      attr_reader :klass
      attr_reader :field_name
      attr_reader :retry_count

      def initialize(klass, field_name, retry_count)
        @create_new_token = Proc.new {|doc|}
        @klass = klass
        @field_name = field_name
        @retry_count = retry_count
        klass.send(:include, Mongoid::Token::Collisions)
        alias_method_with_collision_resolution(:insert)
        alias_method_with_collision_resolution(:upsert)
      end

      def create_new_token_for(document)
        @create_new_token.call(document)
      end

      private
      def alias_method_with_collision_resolution(method)
        handler = self
        adhoc_module = Module.new

        adhoc_module.send(:define_method, method) do |method_options = {}|
          self.resolve_token_collisions handler do
            with(write: { w: 1 }) do
              super(method_options)
            end
          end
        end

        klass.prepend adhoc_module
      end
    end
  end
end
