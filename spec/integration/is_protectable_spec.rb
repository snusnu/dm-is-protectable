require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'
require Pathname(__FILE__).dirname.expand_path        + 'shared_spec'

if HAS_SQLITE3 || HAS_MYSQL || HAS_POSTGRES
  
  describe DataMapper::Is::Protectable do
    
    # --------------------------------------------------------------------------------------------------
    # --------------------------------------------------------------------------------------------------


    describe "Any Model that is NOT protectable" do
      
      before do
        Support.fresh_model "Person"
        Person.auto_migrate!
        @p = Person.new
      end
      
      it "should not have active dm-is-protectable hooks" do
        # active before hooks would mean, that these method
        # calls would fail, because the hook methods rely on
        # methods that are only present, if the Resource is :protectable
        Person.is_protectable?.should be_false
        lambda { @p.firstname = "snu" }.should_not raise_error
        lambda { @p.lastname  = "snu" }.should_not raise_error
        @p.firstname.should == "snu"
        @p.lastname.should  == "snu"
      end
      
    end
        

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