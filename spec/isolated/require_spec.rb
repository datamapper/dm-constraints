shared_examples_for "require 'dm-constraints'" do

  it "extends Model descendants with the constraint API" do
    DataMapper::Model.descendants.any?.should be(true)
    DataMapper::Model.descendants.all? do |model|
      model.respond_to?(:auto_migrate_down_constraints!, true).should be(true)
      model.respond_to?(:auto_migrate_up_constraints!,   true).should be(true)
    end
  end

  it "includes the constraint API into the adapter" do
    @adapter.respond_to?(:constraint_exists?             ).should be(true)
    @adapter.respond_to?(:create_relationship_constraint ).should be(true)
    @adapter.respond_to?(:destroy_relationship_constraint).should be(true)
  end

end
