require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'
require Pathname(__FILE__).dirname.expand_path        + 'shared_spec'

if HAS_SQLITE3 || HAS_MYSQL || HAS_POSTGRES
  
  describe DataMapper::Is::Protectable do
    
    # --------------------------------------------------------------------------------------------------
    # --------------------------------------------------------------------------------------------------
    

    describe "Model.is :protectable" do
      
      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.auto_migrate!
        @p = Person.new
      end
      
      it_should_behave_like "every protectable"
      it_should_behave_like "every not extended protectable"
      it_should_behave_like "default permissions are installed"
      
    end
    
    describe "Model.is :protectable, :defaults => true" do
      
      before do
        Support.fresh_model "Person"
        Person.is :protectable, :defaults => true
        Person.auto_migrate!
        @p = Person.new
      end
      
      it_should_behave_like "every protectable"
      it_should_behave_like "every not extended protectable"
      it_should_behave_like "default permissions are installed"
      
    end
    
    describe "Model.is :protectable, :defaults => false" do
      
      before do
        Support.fresh_model "Person"
        Person.is :protectable, :defaults => false
        Person.auto_migrate!
        @p = Person.new
      end
      
      it_should_behave_like "every protectable"
      it_should_behave_like "every not extended protectable"
      it_should_behave_like "default permissions are not installed"
      
    end
    
    describe "Model.is :protectable, :extended => true" do
      
      before do
        Support.fresh_model "Person"
        Person.is :protectable, :extended => true        
        Person.auto_migrate!
        @p = Person.new
      end
      
      it_should_behave_like "every protectable"
      it_should_behave_like "every extended protectable"
      it_should_behave_like "default permissions are installed"
      
    end
        
    describe "Model.is :protectable, :extended => false" do
      
      before do
        Support.fresh_model "Person"
        Person.is :protectable, :extended => false        
        Person.auto_migrate!
        @p = Person.new
      end
      
      it_should_behave_like "every protectable"
      it_should_behave_like "every not extended protectable"
      it_should_behave_like "default permissions are installed"
      
    end
    
  end
  
end