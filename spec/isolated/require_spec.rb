shared_examples_for "require 'dm-constraints'" do

  it "should include the constraint api in the DataMapper namespace" do
    DataMapper::Model.respond_to?(:auto_migrate_down_constraints!, true).should be_true
    DataMapper::Model.respond_to?(:auto_migrate_up_constraints!,   true).should be_true
  end
  
  it "should include the constraint api into the adapter" do
    @adapter.respond_to?(:constraint_exists?             ).should be_true
    @adapter.respond_to?(:create_relationship_constraint ).should be_true
    @adapter.respond_to?(:destroy_relationship_constraint).should be_true
  end

end
