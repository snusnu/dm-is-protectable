require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'
require Pathname(__FILE__).dirname.expand_path        + 'shared_spec'

if HAS_SQLITE3 || HAS_MYSQL || HAS_POSTGRES
  
  # -----------------------------------------------------------------------------------------------

  describe "Wrong arguments for 'let':" do
    
    describe "using an invalid permission" do
      
      it "should raise 'InvalidPermission'" do
        Support.fresh_model "Person"
        Person.is :protectable
        lambda { Person.let :foo }.should raise_error(DataMapper::Is::Protectable::InvalidPermission)
      end
      
    end
        
    describe "using an unknown property" do
      
      it "should raise 'UnknownProperty'" do
        Support.fresh_model "Person"
        Person.is :protectable
        lambda { Person.let :read, :foo }.should raise_error(DataMapper::Is::Protectable::UnknownProperty)
      end
      
    end
                
    describe "using an invalid unconditional guard" do
      
      it "should raise 'InvalidGuard'" do
        Support.fresh_model "Person"
        Person.is :protectable
        lambda { Person.let :read, :firstname, 1          }.should raise_error(DataMapper::Is::Protectable::InvalidGuard)
        lambda { Person.let :read, :firstname, :bar       }.should raise_error(DataMapper::Is::Protectable::InvalidGuard)
        lambda { Person.let :read, :firstname, "bar"      }.should raise_error(DataMapper::Is::Protectable::InvalidGuard)
        lambda { Person.let :read, :firstname, Object.new }.should raise_error(DataMapper::Is::Protectable::InvalidGuard)
      end
      
    end
                    
    describe "using an invalid guard condition" do
      
      it "should raise 'InvalidGuardCondition'" do
        Support.fresh_model "Person"
        Person.is :protectable
        lambda { Person.let :read, :firstname, :foo => :funny? }.should raise_error(
          DataMapper::Is::Protectable::InvalidGuardCondition
        )
      end
      
    end
                        
    describe "using an invalid conditional guard" do
      
      it "should raise 'InvalidGuard'" do
        Support.fresh_model "Person"
        Person.is :protectable
        lambda { Person.let :read, :firstname, :if => 1    }.should raise_error(
          DataMapper::Is::Protectable::InvalidGuard
        )
        
        # although Person.respond_to?(:bar) is false at that time
        # it is probably unsafe to assume that this guard is invalid
        # maybe bar gets added to this class later via include or some eval magic
        lambda { Person.let :read, :firstname, :if => :bar  }.should_not raise_error
        lambda { Person.let :read, :firstname, :if => "bar" }.should_not raise_error
      end
      
    end
                            
    describe "using multiple guard conditions" do
      
      it "should raise 'InvalidGuard'" do
        Support.fresh_model "Person"
        Person.is :protectable
        lambda { Person.let :read, :firstname, { :if => :funny?, :unless => :funny? } }.should raise_error(
          DataMapper::Is::Protectable::InvalidGuard
        )
      end
      
    end
    
  end
  
  # -----------------------------------------------------------------------------------------------
  
  describe "Empty guard bound to all properties:" do
    
    describe "Person.let :read" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :read
        Person.auto_migrate!
        @p = Person.new
      end

      it_should_behave_like "default permissions are installed"
      it_should_behave_like "read access on all properties is granted"

    end

    describe "Person.let :write" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :write
        Person.auto_migrate!
        @p = Person.new
      end

      it_should_behave_like "default permissions are installed"
      it_should_behave_like "write access on all properties is granted"

    end

    describe "Person.let :access" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :access
        Person.auto_migrate!
        @p = Person.new
      end

      it_should_behave_like "default permissions are installed"
      it_should_behave_like "read and write access on all properties is granted"

    end
  
  end
  
  # -----------------------------------------------------------------------------------------------
  
  describe "Empty guard bound to one property:" do
    
    describe "Person.let :read, :firstname" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :read, :firstname
        Person.auto_migrate!
        @p = Person.new
      end

      it_should_behave_like "default permissions are installed"
      it_should_behave_like "read access on firstname is granted"

    end

    describe "Person.let :write, :firstname" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :write, :firstname
        Person.auto_migrate!
        @p = Person.new
      end

      it_should_behave_like "default permissions are installed"
      it_should_behave_like "write access on firstname is granted"

    end

    describe "Person.let :access, :firstname" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :access, :firstname
        Person.auto_migrate!
        @p = Person.new
      end

      it_should_behave_like "default permissions are installed"
      it_should_behave_like "read and write access on firstname is granted"

    end
  
  end
  
  # -----------------------------------------------------------------------------------------------
  
  describe "Empty guard bound to multiple properties:" do
    
    describe "Person.let :read, [ :firstname, :lastname ]" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :read, [ :firstname, :lastname ]
        Person.auto_migrate!
        @p = Person.new
      end

      it_should_behave_like "default permissions are installed"
      it_should_behave_like "read access on firstname is granted"
      it_should_behave_like "read access on lastname is granted"

    end

    describe "Person.let :write, [ :firstname, :lastname ]" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :write, [ :firstname, :lastname ]
        Person.auto_migrate!
        @p = Person.new
      end

      it_should_behave_like "default permissions are installed"
      it_should_behave_like "write access on firstname is granted"
      it_should_behave_like "write access on lastname is granted"

    end

    describe "Person.let :access, [ :firstname, :lastname ]" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :access, [ :firstname, :lastname ]
        Person.auto_migrate!
        @p = Person.new
      end

      it_should_behave_like "default permissions are installed"
      it_should_behave_like "read and write access on firstname is granted"
      it_should_behave_like "read and write access on lastname is granted"

    end
  
  end
  
  # -----------------------------------------------------------------------------------------------
  
  describe "Boolean guard bound to all properties:" do
    
    describe "Person.let :read, true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :read, true
        Person.auto_migrate!
        @p = Person.new
      end

      it_should_behave_like "default permissions are installed"
      it_should_behave_like "read access on all properties is granted"

    end
        
    describe "Person.let :read, false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :read, false
        Person.auto_migrate!
        @p = Person.new
      end

      it_should_behave_like "read access on all properties is denied"

    end

    describe "Person.let :write, true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :write, true
        Person.auto_migrate!
        @p = Person.new
      end

      it_should_behave_like "default permissions are installed"
      it_should_behave_like "write access on all properties is granted"

    end
    
    describe "Person.let :write, false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :write, false
        Person.auto_migrate!
        @p = Person.new
      end

      it_should_behave_like "write access on all properties is denied"

    end

    describe "Person.let :access, true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :access, true
        Person.auto_migrate!
        @p = Person.new
      end

      it_should_behave_like "default permissions are installed"
      it_should_behave_like "read and write access on all properties is granted"

    end
    
    describe "Person.let :access, false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :access, false
        Person.auto_migrate!
        @p = Person.new
      end

      it_should_behave_like "read and write access on all properties is denied"

    end
  
  end  
  
  # -----------------------------------------------------------------------------------------------
  
  describe "Boolean guard bound to one property:" do
    
    describe "Person.let :read, :firstname, true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :read, :firstname, true
        Person.auto_migrate!
        @p = Person.new
      end

      it_should_behave_like "default permissions are installed"
      it_should_behave_like "read access on firstname is granted"

    end
        
    describe "Person.let :read, :firstname, false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :read, :firstname, false
        Person.auto_migrate!
        @p = Person.new
      end

      it_should_behave_like "default permissions are installed"
      it_should_behave_like "read access on firstname is denied"

    end

    describe "Person.let :write, :firstname, true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :write, :firstname, true
        Person.auto_migrate!
        @p = Person.new
      end

      it_should_behave_like "default permissions are installed"
      it_should_behave_like "write access on firstname is granted"

    end
    
    describe "Person.let :write, :firstname, false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :write, :firstname, false
        Person.auto_migrate!
        @p = Person.new
      end

      it_should_behave_like "default permissions are installed"
      it_should_behave_like "write access on firstname is denied"

    end

    describe "Person.let :access, :firstname, true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :access, :firstname, true
        Person.auto_migrate!
        @p = Person.new
      end

      it_should_behave_like "default permissions are installed"
      it_should_behave_like "read and write access on firstname is granted"

    end
    
    describe "Person.let :access, :firstname, false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :access, :firstname, false
        Person.auto_migrate!
        @p = Person.new
      end

      it_should_behave_like "default permissions are installed"
      it_should_behave_like "read and write access on firstname is denied"

    end
  
  end
  
  # -----------------------------------------------------------------------------------------------
  
  describe "Boolean guard bound to multiple properties:" do
    
    describe "Person.let :read, [ :firstname, :lastname ], true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :read, [ :firstname, :lastname ], true
        Person.auto_migrate!
        @p = Person.new
      end

      it_should_behave_like "default permissions are installed"
      it_should_behave_like "read access on firstname is granted"
      it_should_behave_like "read access on lastname is granted"

    end
        
    describe "Person.let :read, [ :firstname, :lastname ], false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :read, [ :firstname, :lastname ], false
        Person.auto_migrate!
        @p = Person.new
      end

      it_should_behave_like "default permissions are installed"
      it_should_behave_like "read access on firstname is denied"
      it_should_behave_like "read access on lastname is denied"

    end

    describe "Person.let :write, [ :firstname, :lastname ], true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :write, [ :firstname, :lastname ], true
        Person.auto_migrate!
        @p = Person.new
      end

      it_should_behave_like "default permissions are installed"
      it_should_behave_like "write access on firstname is granted"
      it_should_behave_like "write access on lastname is granted"

    end
    
    describe "Person.let :write, [ :firstname, :lastname ], false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :write, [ :firstname, :lastname ], false
        Person.auto_migrate!
        @p = Person.new
      end

      it_should_behave_like "default permissions are installed"
      it_should_behave_like "write access on firstname is denied"
      it_should_behave_like "write access on lastname is denied"

    end

    describe "Person.let :access, [ :firstname, :lastname ], true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :access, [ :firstname, :lastname ], true
        Person.auto_migrate!
        @p = Person.new
      end

      it_should_behave_like "default permissions are installed"
      it_should_behave_like "read and write access on firstname is granted"
      it_should_behave_like "read and write access on lastname is granted"

    end
    
    describe "Person.let :access, [ :firstname, :lastname ], false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :access, [ :firstname, :lastname ], false
        Person.auto_migrate!
        @p = Person.new
      end

      it_should_behave_like "default permissions are installed"
      it_should_behave_like "read and write access on firstname is denied"
      it_should_behave_like "read and write access on lastname is denied"

    end
  
  end
  
  # -----------------------------------------------------------------------------------------------
  
  describe "Instance method guard bound to all properties:" do
    
    describe "Person.let(:read, :if => :funny?) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :read, :if => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "read access on all properties is granted"

    end
        
    describe "Person.let(:read, :if => :funny?) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :read, :if => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "read access on all properties is denied"

    end
        
    describe "Person.let(:read, :unless => :funny?) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :read, :unless => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "read access on all properties is denied"

    end
        
    describe "Person.let(:read, :unless => :funny?) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :read, :unless => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "read access on all properties is granted"

    end

    describe "Person.let(:write, :if => :funny?) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :write, :if => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "write access on all properties is granted"

    end
    
    describe "Person.let(:write, :if => :funny?) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :write, :if => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "write access on all properties is denied"

    end
    
    describe "Person.let(:write, :unless => :funny?) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :write, :unless => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "write access on all properties is denied"

    end
    
    describe "Person.let(:write, :unless => :funny?) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :write, :unless => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "write access on all properties is granted"

    end

    describe "Person.let(:access, :if => :funny?) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :access, :if => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "read and write access on all properties is granted"

    end
    
    describe "Person.let(:access, :if => :funny?) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :access, :if => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "read and write access on all properties is denied"

    end
    
    describe "Person.let(:access, :unless => :funny?) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :access, :unless => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "read and write access on all properties is denied"

    end
    
    describe "Person.let(:access, :unless => :funny?) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :access, :unless => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "read and write access on all properties is granted"

    end
  
  end
  
  # -----------------------------------------------------------------------------------------------
  
  describe "Instance method guard bound to one property:" do
    
    describe "Person.let(:read, :firstname, :if => :funny?) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :read, :firstname, :if => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "read access on firstname is granted"

    end
        
    describe "Person.let(:read, :firstname, :if => :funny?) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :read, :firstname, :if => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "read access on firstname is denied"

    end
        
    describe "Person.let(:read, :firstname, :unless => :funny?) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :read, :firstname, :unless => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "read access on firstname is denied"

    end
        
    describe "Person.let(:read, :firstname, :unless => :funny?) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :read, :firstname, :unless => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "read access on firstname is granted"

    end

    describe "Person.let(:write, :firstname, :if => :funny?) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :write, :firstname, :if => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "write access on firstname is granted"

    end
    
    describe "Person.let(:write, :firstname, :if => :funny?) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :write, :firstname, :if => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "write access on firstname is denied"

    end
    
    describe "Person.let(:write, :firstname, :unless => :funny?) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :write, :firstname, :unless => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "write access on firstname is denied"

    end
    
    describe "Person.let(:write, :firstname, :unless => :funny?) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :write, :firstname, :unless => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "write access on firstname is granted"

    end

    describe "Person.let(:access, :firstname, :if => :funny?) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :access, :firstname, :if => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "read and write access on firstname is granted"

    end
    
    describe "Person.let(:access, :firstname, :if => :funny?) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :access, :firstname, :if => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "read and write access on firstname is denied"

    end
    
    describe "Person.let(:access, :firstname, :unless => :funny?) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :access, :firstname, :unless => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "read and write access on firstname is denied"

    end
    
    describe "Person.let(:access, :firstname, :unless => :funny?) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :access, :firstname, :unless => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "read and write access on firstname is granted"

    end
  
  end
  
  # -----------------------------------------------------------------------------------------------
  
  describe "Instance method guard bound to multiple properties:" do
    
    describe "Person.let(:read, [ :firstname, :lastname ], :if => :funny?) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :read, [ :firstname, :lastname ], :if => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "read access on firstname is granted"
      it_should_behave_like "read access on lastname is granted"

    end
        
    describe "Person.let(:read, [ :firstname, :lastname ], :if => :funny?) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :read, [ :firstname, :lastname ], :if => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "read access on firstname is denied"
      it_should_behave_like "read access on lastname is denied"

    end
        
    describe "Person.let(:read, [ :firstname, :lastname ], :unless => :funny?) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :read, [ :firstname, :lastname ], :unless => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "read access on firstname is denied"
      it_should_behave_like "read access on lastname is denied"

    end
        
    describe "Person.let(:read, [ :firstname, :lastname ], :unless => :funny?) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :read, [ :firstname, :lastname ], :unless => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "read access on firstname is granted"
      it_should_behave_like "read access on lastname is granted"

    end

    describe "Person.let(:write, [ :firstname, :lastname ], :if => :funny?) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :write, [ :firstname, :lastname ], :if => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "write access on firstname is granted"
      it_should_behave_like "write access on lastname is granted"

    end
    
    describe "Person.let(:write, [ :firstname, :lastname ], :if => :funny?) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :write, [ :firstname, :lastname ], :if => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "write access on firstname is denied"
      it_should_behave_like "write access on lastname is denied"

    end
    
    describe "Person.let(:write, [ :firstname, :lastname ], :unless => :funny?) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :write, [ :firstname, :lastname ], :unless => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "write access on firstname is denied"
      it_should_behave_like "write access on lastname is denied"

    end
    
    describe "Person.let(:write, [ :firstname, :lastname ], :unless => :funny?) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :write, [ :firstname, :lastname ], :unless => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "write access on firstname is granted"
      it_should_behave_like "write access on lastname is granted"

    end

    describe "Person.let(:access, [ :firstname, :lastname ], :if => :funny?) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :access, [ :firstname, :lastname ], :if => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "read and write access on firstname is granted"
      it_should_behave_like "read and write access on lastname is granted"

    end
    
    describe "Person.let(:access, [ :firstname, :lastname ], :if => :funny?) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :access, [ :firstname, :lastname ], :if => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "read and write access on firstname is denied"
      it_should_behave_like "read and write access on lastname is denied"

    end
    
    describe "Person.let(:access, [ :firstname, :lastname ], :unless => :funny?) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :access, [ :firstname, :lastname ], :unless => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "read and write access on firstname is denied"
      it_should_behave_like "read and write access on lastname is denied"

    end
    
    describe "Person.let(:access, [ :firstname, :lastname ], :unless => :funny?) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :access, [ :firstname, :lastname ], :unless => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "read and write access on firstname is granted"
      it_should_behave_like "read and write access on lastname is granted"

    end
  
  end
  
  # -----------------------------------------------------------------------------------------------
  
  describe "Block guard bound to all properties:" do
    
    describe "Person.let(:read, :if => lambda { |p| p.funny? }) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :read, :if => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "read access on all properties is granted"

    end
        
    describe "Person.let(:read, :if => lambda { |p| p.funny? }) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :read, :if => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "read access on all properties is denied"

    end
        
    describe "Person.let(:read, :unless => lambda { |p| p.funny? }) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :read, :unless => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "read access on all properties is denied"

    end
        
    describe "Person.let(:read, :unless => lambda { |p| p.funny? }) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :read, :unless => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "read access on all properties is granted"

    end

    describe "Person.let(:write, :if => lambda { |p| p.funny? }) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :write, :if => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "write access on all properties is granted"

    end
    
    describe "Person.let(:write, :if => lambda { |p| p.funny? }) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :write, :if => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "write access on all properties is denied"

    end
    
    describe "Person.let(:write, :unless => lambda { |p| p.funny? }) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :write, :unless => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "write access on all properties is denied"

    end
    
    describe "Person.let(:write, :unless => lambda { |p| p.funny? }) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :write, :unless => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "write access on all properties is granted"

    end

    describe "Person.let(:access, :if => lambda { |p| p.funny? }) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :access, :if => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "read and write access on all properties is granted"

    end
    
    describe "Person.let(:access, :if => lambda { |p| p.funny? }) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :access, :if => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "read and write access on all properties is denied"

    end
    
    describe "Person.let(:access, :unless => lambda { |p| p.funny? }) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :access, :unless => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "read and write access on all properties is denied"

    end
    
    describe "Person.let(:access, :unless => lambda { |p| p.funny? }) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :access, :unless => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "read and write access on all properties is granted"

    end
  
  end
  
  # -----------------------------------------------------------------------------------------------
  
  describe "Block guard bound to one property:" do
    
    describe "Person.let(:read, :firstname, :if => lambda { |p| p.funny? }) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :read, :firstname, :if => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "read access on firstname is granted"

    end
        
    describe "Person.let(:read, :firstname, :if => lambda { |p| p.funny? }) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :read, :firstname, :if => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "read access on firstname is denied"

    end
        
    describe "Person.let(:read, :firstname, :unless => lambda { |p| p.funny? }) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :read, :firstname, :unless => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "read access on firstname is denied"

    end
        
    describe "Person.let(:read, :firstname, :unless => lambda { |p| p.funny? }) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :read, :firstname, :unless => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "read access on firstname is granted"

    end

    describe "Person.let(:write, :firstname, :if => lambda { |p| p.funny? }) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :write, :firstname, :if => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "write access on firstname is granted"

    end
    
    describe "Person.let(:write, :firstname, :if => lambda { |p| p.funny? }) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :write, :firstname, :if => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "write access on firstname is denied"

    end
    
    describe "Person.let(:write, :firstname, :unless => lambda { |p| p.funny? }) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :write, :firstname, :unless => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "write access on firstname is denied"

    end
    
    describe "Person.let(:write, :firstname, :unless => lambda { |p| p.funny? }) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :write, :firstname, :unless => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "write access on firstname is granted"

    end

    describe "Person.let(:access, :firstname, :if => lambda { |p| p.funny? }) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :access, :firstname, :if => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "read and write access on firstname is granted"

    end
    
    describe "Person.let(:access, :firstname, :if => lambda { |p| p.funny? }) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :access, :firstname, :if => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "read and write access on firstname is denied"

    end
    
    describe "Person.let(:access, :firstname, :unless => lambda { |p| p.funny? }) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :access, :firstname, :unless => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "read and write access on firstname is denied"

    end
    
    describe "Person.let(:access, :firstname, :unless => lambda { |p| p.funny? }) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :access, :firstname, :unless => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "read and write access on firstname is granted"

    end
  
  end
  
  # -----------------------------------------------------------------------------------------------
  
  describe "Block guard bound to multiple properties:" do
    
    describe "Person.let(:read, [ :firstname, :lastname ], :if => lambda { |p| p.funny? }) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :read, [ :firstname, :lastname ], :if => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "read access on firstname is granted"
      it_should_behave_like "read access on lastname is granted"

    end
        
    describe "Person.let(:read, [ :firstname, :lastname ], :if => lambda { |p| p.funny? }) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :read, [ :firstname, :lastname ], :if => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "read access on firstname is denied"
      it_should_behave_like "read access on lastname is denied"

    end
        
    describe "Person.let(:read, [ :firstname, :lastname ], :unless => lambda { |p| p.funny? }) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :read, [ :firstname, :lastname ], :unless => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "read access on firstname is denied"
      it_should_behave_like "read access on lastname is denied"

    end
        
    describe "Person.let(:read, [ :firstname, :lastname ], :unless => lambda { |p| p.funny? }) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :read, [ :firstname, :lastname ], :unless => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "read access on firstname is granted"
      it_should_behave_like "read access on lastname is granted"

    end

    describe "Person.let(:write, [ :firstname, :lastname ], :if => lambda { |p| p.funny? }) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :write, [ :firstname, :lastname ], :if => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "write access on firstname is granted"
      it_should_behave_like "write access on lastname is granted"

    end
    
    describe "Person.let(:write, [ :firstname, :lastname ], :if => lambda { |p| p.funny? }) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :write, [ :firstname, :lastname ], :if => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "write access on firstname is denied"
      it_should_behave_like "write access on lastname is denied"

    end
    
    describe "Person.let(:write, [ :firstname, :lastname ], :unless => lambda { |p| p.funny? }) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :write, [ :firstname, :lastname ], :unless => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "write access on firstname is denied"
      it_should_behave_like "write access on lastname is denied"

    end
    
    describe "Person.let(:write, [ :firstname, :lastname ], :unless => lambda { |p| p.funny? }) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :write, [ :firstname, :lastname ], :unless => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "write access on firstname is granted"
      it_should_behave_like "write access on lastname is granted"

    end

    describe "Person.let(:access, [ :firstname, :lastname ], :if => lambda { |p| p.funny? }) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :access, [ :firstname, :lastname ], :if => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "read and write access on firstname is granted"
      it_should_behave_like "read and write access on lastname is granted"

    end
    
    describe "Person.let(:access, [ :firstname, :lastname ], :if => lambda { |p| p.funny? }) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :access, [ :firstname, :lastname ], :if => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "read and write access on firstname is denied"
      it_should_behave_like "read and write access on lastname is denied"

    end
    
    describe "Person.let(:access, [ :firstname, :lastname ], :unless => lambda { |p| p.funny? }) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :access, [ :firstname, :lastname ], :unless => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "read and write access on firstname is denied"
      it_should_behave_like "read and write access on lastname is denied"

    end
    
    describe "Person.let(:access, [ :firstname, :lastname ], :unless => lambda { |p| p.funny? }) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.let :access, [ :firstname, :lastname ], :unless => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "read and write access on firstname is granted"
      it_should_behave_like "read and write access on lastname is granted"

    end
  
  end
end