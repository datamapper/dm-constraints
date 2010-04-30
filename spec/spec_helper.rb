require 'rubygems'
require 'dm-constraints'

require 'dm-migrations'
require 'dm-core/spec/setup'

DataMapper::Spec.setup

Spec::Runner.configure do |config|
  config.after :all do
    # global model cleanup
    descendants = DataMapper::Model.descendants.to_a
    while model = descendants.shift
      descendants.concat(model.descendants.to_a - [ model ])

      parts         = model.name.split('::')
      constant_name = parts.pop.to_sym
      base          = parts.empty? ? Object : Object.full_const_get(parts.join('::'))

      if base.const_defined?(constant_name)
        base.send(:remove_const, constant_name)
      end

      DataMapper::Model.descendants.delete(model)
    end
  end

  config.before do
    DataMapper.auto_migrate!
  end

  config.after do
    DataMapper.send(:auto_migrate_down!, @repository.name)
  end
end
