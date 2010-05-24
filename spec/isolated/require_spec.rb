shared_examples_for "require 'dm-constraints'" do

  it "should include the constraint api in the DataMapper namespace" do
    DataMapper::Model.respond_to?(:auto_migrate_down_constraints!, true).should be(true)
    DataMapper::Model.respond_to?(:auto_migrate_up_constraints!,   true).should be(true)
  end

  it "should include the constraint api into the adapter" do
    @adapter.respond_to?(:constraint_exists?             ).should be(true)
    @adapter.respond_to?(:create_relationship_constraint ).should be(true)
    @adapter.respond_to?(:destroy_relationship_constraint).should be(true)
  end

end
