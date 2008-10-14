require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'
require Pathname(__FILE__).dirname.expand_path        + 'shared_spec'

if HAS_SQLITE3 || HAS_MYSQL || HAS_POSTGRES
  
  # -----------------------------------------------------------------------------------------------

  describe "Wrong arguments for 'deny':" do
    
    describe "using an invalid permission" do
      
      it "should raise 'InvalidPermission'" do
        Support.fresh_model "Person"
        Person.is :protectable
        lambda { Person.deny :foo }.should raise_error(DataMapper::Is::Protectable::InvalidPermission)
      end
      
    end
        
    describe "using an unknown property" do
      
      it "should raise 'UnknownProperty'" do
        Support.fresh_model "Person"
        Person.is :protectable
        lambda { Person.deny :read, :foo }.should raise_error(DataMapper::Is::Protectable::UnknownProperty)
      end
      
    end
                
    describe "using an invalid unconditional guard" do
      
      it "should raise 'InvalidGuard'" do
        Support.fresh_model "Person"
        Person.is :protectable
        lambda { Person.deny :read, :firstname, 1          }.should raise_error(DataMapper::Is::Protectable::InvalidGuard)
        lambda { Person.deny :read, :firstname, :bar       }.should raise_error(DataMapper::Is::Protectable::InvalidGuard)
        lambda { Person.deny :read, :firstname, "bar"      }.should raise_error(DataMapper::Is::Protectable::InvalidGuard)
        lambda { Person.deny :read, :firstname, Object.new }.should raise_error(DataMapper::Is::Protectable::InvalidGuard)
      end
      
    end
                    
    describe "using an invalid guard condition" do
      
      it "should raise 'InvalidGuardCondition'" do
        Support.fresh_model "Person"
        Person.is :protectable
        lambda { Person.deny :read, :firstname, :foo => :funny? }.should raise_error(
          DataMapper::Is::Protectable::InvalidGuardCondition
        )
      end
      
    end
                        
    describe "using an invalid conditional guard" do
      
      it "should raise 'InvalidGuard'" do
        Support.fresh_model "Person"
        Person.is :protectable
        lambda { Person.deny :read, :firstname, :if => 1    }.should raise_error(
          DataMapper::Is::Protectable::InvalidGuard
        )
        
        # although Person.respond_to?(:bar) is false at that time
        # it is probably unsafe to assume that this guard is invalid
        # maybe bar gets added to this class later via include or some eval magic
        lambda { Person.deny :read, :firstname, :if => :bar  }.should_not raise_error
        lambda { Person.deny :read, :firstname, :if => "bar" }.should_not raise_error
      end
      
    end
                            
    describe "using multiple guard conditions" do
      
      it "should raise 'InvalidGuard'" do
        Support.fresh_model "Person"
        Person.is :protectable
        lambda { Person.deny :read, :firstname, { :if => :funny?, :unless => :funny? } }.should raise_error(
          DataMapper::Is::Protectable::InvalidGuard
        )
      end
      
    end
    
  end
  
  # -----------------------------------------------------------------------------------------------
  
  describe "Empty guard bound to all properties:" do
    
    describe "Person.deny :read" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :read
        Person.auto_migrate!
        @p = Person.new
      end

      it_should_behave_like "read access on all properties is denied"

    end

    describe "Person.deny :write" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :write
        Person.auto_migrate!
        @p = Person.new
      end

      it_should_behave_like "write access on all properties is denied"

    end

    describe "Person.deny :access" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :access
        Person.auto_migrate!
        @p = Person.new
      end

      it_should_behave_like "read and write access on all properties is denied"

    end
  
  end
  
  # -----------------------------------------------------------------------------------------------
  
  describe "Empty guard bound to one property:" do
    
    describe "Person.deny :read, :firstname" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :read, :firstname
        Person.auto_migrate!
        @p = Person.new
      end

      it_should_behave_like "default permissions are installed"
      it_should_behave_like "read access on firstname is denied"

    end

    describe "Person.deny :write, :firstname" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :write, :firstname
        Person.auto_migrate!
        @p = Person.new
      end

      it_should_behave_like "default permissions are installed"
      it_should_behave_like "write access on firstname is denied"

    end

    describe "Person.deny :access, :firstname" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :access, :firstname
        Person.auto_migrate!
        @p = Person.new
      end

      it_should_behave_like "default permissions are installed"
      it_should_behave_like "read and write access on firstname is denied"

    end
  
  end
  
  # -----------------------------------------------------------------------------------------------
  
  describe "Empty guard bound to multiple properties:" do
    
    describe "Person.deny :read, [ :firstname, :lastname ]" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :read, [ :firstname, :lastname ]
        Person.auto_migrate!
        @p = Person.new
      end

      it_should_behave_like "default permissions are installed"
      it_should_behave_like "read access on firstname is denied"
      it_should_behave_like "read access on lastname is denied"

    end

    describe "Person.deny :write, [ :firstname, :lastname ]" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :write, [ :firstname, :lastname ]
        Person.auto_migrate!
        @p = Person.new
      end

      it_should_behave_like "default permissions are installed"
      it_should_behave_like "write access on firstname is denied"
      it_should_behave_like "write access on lastname is denied"

    end

    describe "Person.deny :access, [ :firstname, :lastname ]" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :access, [ :firstname, :lastname ]
        Person.auto_migrate!
        @p = Person.new
      end

      it_should_behave_like "default permissions are installed"
      it_should_behave_like "read and write access on firstname is denied"
      it_should_behave_like "read and write access on lastname is denied"

    end
  
  end
  
  # -----------------------------------------------------------------------------------------------
  
  describe "Boolean guard bound to all properties:" do
    
    describe "Person.deny :read, true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :read, true
        Person.auto_migrate!
        @p = Person.new
      end

      it_should_behave_like "read access on all properties is denied"

    end
        
    describe "Person.deny :read, false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :read, false
        Person.auto_migrate!
        @p = Person.new
      end

      it_should_behave_like "default permissions are installed"
      it_should_behave_like "read access on all properties is granted"

    end

    describe "Person.deny :write, true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :write, true
        Person.auto_migrate!
        @p = Person.new
      end

      it_should_behave_like "write access on all properties is denied"

    end
    
    describe "Person.deny :write, false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :write, false
        Person.auto_migrate!
        @p = Person.new
      end

      it_should_behave_like "default permissions are installed"
      it_should_behave_like "write access on all properties is granted"

    end

    describe "Person.deny :access, true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :access, true
        Person.auto_migrate!
        @p = Person.new
      end

      it_should_behave_like "read and write access on all properties is denied"

    end
    
    describe "Person.deny :access, false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :access, false
        Person.auto_migrate!
        @p = Person.new
      end

      it_should_behave_like "default permissions are installed"
      it_should_behave_like "read and write access on all properties is granted"

    end
  
  end  
  
  # -----------------------------------------------------------------------------------------------
  
  describe "Boolean guard bound to one property:" do
    
    describe "Person.deny :read, :firstname, true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :read, :firstname, true
        Person.auto_migrate!
        @p = Person.new
      end

      it_should_behave_like "default permissions are installed"
      it_should_behave_like "read access on firstname is denied"

    end
        
    describe "Person.deny :read, :firstname, false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :read, :firstname, false
        Person.auto_migrate!
        @p = Person.new
      end

      it_should_behave_like "default permissions are installed"
      it_should_behave_like "read access on firstname is granted"

    end

    describe "Person.deny :write, :firstname, true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :write, :firstname, true
        Person.auto_migrate!
        @p = Person.new
      end

      it_should_behave_like "default permissions are installed"
      it_should_behave_like "write access on firstname is denied"

    end
    
    describe "Person.deny :write, :firstname, false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :write, :firstname, false
        Person.auto_migrate!
        @p = Person.new
      end

      it_should_behave_like "default permissions are installed"
      it_should_behave_like "write access on firstname is granted"

    end

    describe "Person.deny :access, :firstname, true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :access, :firstname, true
        Person.auto_migrate!
        @p = Person.new
      end

      it_should_behave_like "default permissions are installed"
      it_should_behave_like "read and write access on firstname is denied"

    end
    
    describe "Person.deny :access, :firstname, false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :access, :firstname, false
        Person.auto_migrate!
        @p = Person.new
      end

      it_should_behave_like "default permissions are installed"
      it_should_behave_like "read and write access on firstname is granted"

    end
  
  end
  
  # -----------------------------------------------------------------------------------------------
  
  describe "Boolean guard bound to multiple properties:" do
    
    describe "Person.deny :read, [ :firstname, :lastname ], true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :read, [ :firstname, :lastname ], true
        Person.auto_migrate!
        @p = Person.new
      end

      it_should_behave_like "default permissions are installed"
      it_should_behave_like "read access on firstname is denied"
      it_should_behave_like "read access on lastname is denied"

    end
        
    describe "Person.deny :read, [ :firstname, :lastname ], false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :read, [ :firstname, :lastname ], false
        Person.auto_migrate!
        @p = Person.new
      end

      it_should_behave_like "default permissions are installed"
      it_should_behave_like "read access on firstname is granted"
      it_should_behave_like "read access on lastname is granted"

    end

    describe "Person.deny :write, [ :firstname, :lastname ], true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :write, [ :firstname, :lastname ], true
        Person.auto_migrate!
        @p = Person.new
      end

      it_should_behave_like "default permissions are installed"
      it_should_behave_like "write access on firstname is denied"
      it_should_behave_like "write access on lastname is denied"

    end
    
    describe "Person.deny :write, [ :firstname, :lastname ], false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :write, [ :firstname, :lastname ], false
        Person.auto_migrate!
        @p = Person.new
      end

      it_should_behave_like "default permissions are installed"
      it_should_behave_like "write access on firstname is granted"
      it_should_behave_like "write access on lastname is granted"

    end

    describe "Person.deny :access, [ :firstname, :lastname ], true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :access, [ :firstname, :lastname ], true
        Person.auto_migrate!
        @p = Person.new
      end

      it_should_behave_like "default permissions are installed"
      it_should_behave_like "read and write access on firstname is denied"
      it_should_behave_like "read and write access on lastname is denied"

    end
    
    describe "Person.deny :access, [ :firstname, :lastname ], false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :access, [ :firstname, :lastname ], false
        Person.auto_migrate!
        @p = Person.new
      end

      it_should_behave_like "default permissions are installed"
      it_should_behave_like "read and write access on firstname is granted"
      it_should_behave_like "read and write access on lastname is granted"

    end
  
  end
  
  # -----------------------------------------------------------------------------------------------
  
  describe "Instance method guard bound to all properties:" do
    
    describe "Person.deny(:read, :if => :funny?) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :read, :if => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "read access on all properties is denied"

    end
        
    describe "Person.deny(:read, :if => :funny?) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :read, :if => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "read access on all properties is granted"

    end
        
    describe "Person.deny(:read, :unless => :funny?) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :read, :unless => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "read access on all properties is granted"

    end
        
    describe "Person.deny(:read, :unless => :funny?) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :read, :unless => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "read access on all properties is denied"

    end

    describe "Person.deny(:write, :if => :funny?) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :write, :if => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "write access on all properties is denied"

    end
    
    describe "Person.deny(:write, :if => :funny?) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :write, :if => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "write access on all properties is granted"

    end
    
    describe "Person.deny(:write, :unless => :funny?) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :write, :unless => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "write access on all properties is granted"

    end
    
    describe "Person.deny(:write, :unless => :funny?) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :write, :unless => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "write access on all properties is denied"

    end

    describe "Person.deny(:access, :if => :funny?) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :access, :if => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "read and write access on all properties is denied"

    end
    
    describe "Person.deny(:access, :if => :funny?) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :access, :if => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "read and write access on all properties is granted"

    end
    
    describe "Person.deny(:access, :unless => :funny?) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :access, :unless => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "read and write access on all properties is granted"

    end
    
    describe "Person.deny(:access, :unless => :funny?) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :access, :unless => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "read and write access on all properties is denied"

    end
  
  end
  
  # -----------------------------------------------------------------------------------------------
  
  describe "Instance method guard bound to one property:" do
    
    describe "Person.deny(:read, :firstname, :if => :funny?) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :read, :firstname, :if => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "read access on firstname is denied"

    end
        
    describe "Person.deny(:read, :firstname, :if => :funny?) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :read, :firstname, :if => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "read access on firstname is granted"

    end
        
    describe "Person.deny(:read, :firstname, :unless => :funny?) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :read, :firstname, :unless => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "read access on firstname is granted"

    end
        
    describe "Person.deny(:read, :firstname, :unless => :funny?) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :read, :firstname, :unless => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "read access on firstname is denied"

    end

    describe "Person.deny(:write, :firstname, :if => :funny?) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :write, :firstname, :if => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "write access on firstname is denied"

    end
    
    describe "Person.deny(:write, :firstname, :if => :funny?) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :write, :firstname, :if => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "write access on firstname is granted"

    end
    
    describe "Person.deny(:write, :firstname, :unless => :funny?) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :write, :firstname, :unless => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "write access on firstname is granted"

    end
    
    describe "Person.deny(:write, :firstname, :unless => :funny?) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :write, :firstname, :unless => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "write access on firstname is denied"

    end

    describe "Person.deny(:access, :firstname, :if => :funny?) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :access, :firstname, :if => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "read and write access on firstname is denied"

    end
    
    describe "Person.deny(:access, :firstname, :if => :funny?) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :access, :firstname, :if => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "read and write access on firstname is granted"

    end
    
    describe "Person.deny(:access, :firstname, :unless => :funny?) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :access, :firstname, :unless => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "read and write access on firstname is granted"

    end
    
    describe "Person.deny(:access, :firstname, :unless => :funny?) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :access, :firstname, :unless => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "read and write access on firstname is denied"

    end
  
  end
  
  # -----------------------------------------------------------------------------------------------
  
  describe "Instance method guard bound to multiple properties:" do
    
    describe "Person.deny(:read, [ :firstname, :lastname ], :if => :funny?) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :read, [ :firstname, :lastname ], :if => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "read access on firstname is denied"
      it_should_behave_like "read access on lastname is denied"

    end
        
    describe "Person.deny(:read, [ :firstname, :lastname ], :if => :funny?) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :read, [ :firstname, :lastname ], :if => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "read access on firstname is granted"
      it_should_behave_like "read access on lastname is granted"

    end
        
    describe "Person.deny(:read, [ :firstname, :lastname ], :unless => :funny?) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :read, [ :firstname, :lastname ], :unless => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "read access on firstname is granted"
      it_should_behave_like "read access on lastname is granted"

    end
        
    describe "Person.deny(:read, [ :firstname, :lastname ], :unless => :funny?) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :read, [ :firstname, :lastname ], :unless => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "read access on firstname is denied"
      it_should_behave_like "read access on lastname is denied"

    end

    describe "Person.deny(:write, [ :firstname, :lastname ], :if => :funny?) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :write, [ :firstname, :lastname ], :if => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "write access on firstname is denied"
      it_should_behave_like "write access on lastname is denied"

    end
    
    describe "Person.deny(:write, [ :firstname, :lastname ], :if => :funny?) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :write, [ :firstname, :lastname ], :if => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "write access on firstname is granted"
      it_should_behave_like "write access on lastname is granted"

    end
    
    describe "Person.deny(:write, [ :firstname, :lastname ], :unless => :funny?) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :write, [ :firstname, :lastname ], :unless => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "write access on firstname is granted"
      it_should_behave_like "write access on lastname is granted"

    end
    
    describe "Person.deny(:write, [ :firstname, :lastname ], :unless => :funny?) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :write, [ :firstname, :lastname ], :unless => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "write access on firstname is denied"
      it_should_behave_like "write access on lastname is denied"

    end

    describe "Person.deny(:access, [ :firstname, :lastname ], :if => :funny?) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :access, [ :firstname, :lastname ], :if => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "read and write access on firstname is denied"
      it_should_behave_like "read and write access on lastname is denied"

    end
    
    describe "Person.deny(:access, [ :firstname, :lastname ], :if => :funny?) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :access, [ :firstname, :lastname ], :if => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "read and write access on firstname is granted"
      it_should_behave_like "read and write access on lastname is granted"

    end
    
    describe "Person.deny(:access, [ :firstname, :lastname ], :unless => :funny?) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :access, [ :firstname, :lastname ], :unless => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "read and write access on firstname is granted"
      it_should_behave_like "read and write access on lastname is granted"

    end
    
    describe "Person.deny(:access, [ :firstname, :lastname ], :unless => :funny?) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :access, [ :firstname, :lastname ], :unless => :funny?
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "read and write access on firstname is denied"
      it_should_behave_like "read and write access on lastname is denied"

    end
  
  end
  
  # -----------------------------------------------------------------------------------------------
  
  describe "Block guard bound to all properties:" do
    
    describe "Person.deny(:read, :if => lambda { |p| p.funny? }) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :read, :if => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "read access on all properties is denied"

    end
        
    describe "Person.deny(:read, :if => lambda { |p| p.funny? }) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :read, :if => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "read access on all properties is granted"

    end
        
    describe "Person.deny(:read, :unless => lambda { |p| p.funny? }) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :read, :unless => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "read access on all properties is granted"

    end
        
    describe "Person.deny(:read, :unless => lambda { |p| p.funny? }) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :read, :unless => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "read access on all properties is denied"

    end

    describe "Person.deny(:write, :if => lambda { |p| p.funny? }) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :write, :if => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "write access on all properties is denied"

    end
    
    describe "Person.deny(:write, :if => lambda { |p| p.funny? }) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :write, :if => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "write access on all properties is granted"

    end
    
    describe "Person.deny(:write, :unless => lambda { |p| p.funny? }) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :write, :unless => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "write access on all properties is granted"

    end
    
    describe "Person.deny(:write, :unless => lambda { |p| p.funny? }) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :write, :unless => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "write access on all properties is denied"

    end

    describe "Person.deny(:access, :if => lambda { |p| p.funny? }) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :access, :if => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "read and write access on all properties is denied"

    end
    
    describe "Person.deny(:access, :if => lambda { |p| p.funny? }) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :access, :if => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "read and write access on all properties is granted"

    end
    
    describe "Person.deny(:access, :unless => lambda { |p| p.funny? }) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :access, :unless => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "read and write access on all properties is granted"

    end
    
    describe "Person.deny(:access, :unless => lambda { |p| p.funny? }) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :access, :unless => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "read and write access on all properties is denied"

    end
  
  end
  
  # -----------------------------------------------------------------------------------------------
  
  describe "Block guard bound to one property:" do
    
    describe "Person.deny(:read, :firstname, :if => lambda { |p| p.funny? }) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :read, :firstname, :if => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "read access on firstname is denied"

    end
        
    describe "Person.deny(:read, :firstname, :if => lambda { |p| p.funny? }) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :read, :firstname, :if => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "read access on firstname is granted"

    end
        
    describe "Person.deny(:read, :firstname, :unless => lambda { |p| p.funny? }) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :read, :firstname, :unless => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "read access on firstname is granted"

    end
        
    describe "Person.deny(:read, :firstname, :unless => lambda { |p| p.funny? }) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :read, :firstname, :unless => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "read access on firstname is denied"

    end

    describe "Person.deny(:write, :firstname, :if => lambda { |p| p.funny? }) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :write, :firstname, :if => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "write access on firstname is denied"

    end
    
    describe "Person.deny(:write, :firstname, :if => lambda { |p| p.funny? }) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :write, :firstname, :if => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "write access on firstname is granted"

    end
    
    describe "Person.deny(:write, :firstname, :unless => lambda { |p| p.funny? }) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :write, :firstname, :unless => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "write access on firstname is granted"

    end
    
    describe "Person.deny(:write, :firstname, :unless => lambda { |p| p.funny? }) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :write, :firstname, :unless => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "write access on firstname is denied"

    end

    describe "Person.deny(:access, :firstname, :if => lambda { |p| p.funny? }) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :access, :firstname, :if => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "read and write access on firstname is denied"

    end
    
    describe "Person.deny(:access, :firstname, :if => lambda { |p| p.funny? }) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :access, :firstname, :if => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "read and write access on firstname is granted"

    end
    
    describe "Person.deny(:access, :firstname, :unless => lambda { |p| p.funny? }) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :access, :firstname, :unless => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "read and write access on firstname is granted"

    end
    
    describe "Person.deny(:access, :firstname, :unless => lambda { |p| p.funny? }) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :access, :firstname, :unless => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "read and write access on firstname is denied"

    end
  
  end
  
  # -----------------------------------------------------------------------------------------------
  
  describe "Block guard bound to multiple properties:" do
    
    describe "Person.deny(:read, [ :firstname, :lastname ], :if => lambda { |p| p.funny? }) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :read, [ :firstname, :lastname ], :if => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "read access on firstname is denied"
      it_should_behave_like "read access on lastname is denied"

    end
        
    describe "Person.deny(:read, [ :firstname, :lastname ], :if => lambda { |p| p.funny? }) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :read, [ :firstname, :lastname ], :if => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "read access on firstname is granted"
      it_should_behave_like "read access on lastname is granted"

    end
        
    describe "Person.deny(:read, [ :firstname, :lastname ], :unless => lambda { |p| p.funny? }) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :read, [ :firstname, :lastname ], :unless => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "read access on firstname is granted"
      it_should_behave_like "read access on lastname is granted"

    end
        
    describe "Person.deny(:read, [ :firstname, :lastname ], :unless => lambda { |p| p.funny? }) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :read, [ :firstname, :lastname ], :unless => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "read access on firstname is denied"
      it_should_behave_like "read access on lastname is denied"

    end

    describe "Person.deny(:write, [ :firstname, :lastname ], :if => lambda { |p| p.funny? }) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :write, [ :firstname, :lastname ], :if => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "write access on firstname is denied"
      it_should_behave_like "write access on lastname is denied"

    end
    
    describe "Person.deny(:write, [ :firstname, :lastname ], :if => lambda { |p| p.funny? }) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :write, [ :firstname, :lastname ], :if => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "write access on firstname is granted"
      it_should_behave_like "write access on lastname is granted"

    end
    
    describe "Person.deny(:write, [ :firstname, :lastname ], :unless => lambda { |p| p.funny? }) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :write, [ :firstname, :lastname ], :unless => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "write access on firstname is granted"
      it_should_behave_like "write access on lastname is granted"

    end
    
    describe "Person.deny(:write, [ :firstname, :lastname ], :unless => lambda { |p| p.funny? }) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :write, [ :firstname, :lastname ], :unless => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "write access on firstname is denied"
      it_should_behave_like "write access on lastname is denied"

    end

    describe "Person.deny(:access, [ :firstname, :lastname ], :if => lambda { |p| p.funny? }) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :access, [ :firstname, :lastname ], :if => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "read and write access on firstname is denied"
      it_should_behave_like "read and write access on lastname is denied"

    end
    
    describe "Person.deny(:access, [ :firstname, :lastname ], :if => lambda { |p| p.funny? }) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :access, [ :firstname, :lastname ], :if => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "read and write access on firstname is granted"
      it_should_behave_like "read and write access on lastname is granted"

    end
    
    describe "Person.deny(:access, [ :firstname, :lastname ], :unless => lambda { |p| p.funny? }) with :funny? returning true" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :access, [ :firstname, :lastname ], :unless => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = true
      end

      it_should_behave_like "read and write access on firstname is granted"
      it_should_behave_like "read and write access on lastname is granted"

    end
    
    describe "Person.deny(:access, [ :firstname, :lastname ], :unless => lambda { |p| p.funny? }) with :funny? returning false" do

      before do
        Support.fresh_model "Person"
        Person.is :protectable
        Person.deny :access, [ :firstname, :lastname ], :unless => lambda { |p| p.funny? }
        Person.auto_migrate!
        @p = Person.new
        @p.funny = false
      end

      it_should_behave_like "read and write access on firstname is denied"
      it_should_behave_like "read and write access on lastname is denied"

    end
  
  end
end