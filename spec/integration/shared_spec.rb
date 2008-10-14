describe "every protectable", :shared => true do

  it "should define a 'let' class method" do
    Person.respond_to?(:let).should be_true
  end
  
  it "should define a 'deny' class method" do
    Person.respond_to?(:deny).should be_true
  end
  
  
  it "should allow to build new records with only default values" do
    lambda { p = Person.new }.should_not raise_error
  end
  
  it "should allow to create records with only default values" do
    lambda { Person.create }.should_not raise_error
  end
  
  
  it "should define a 'readable?' instance method" do
    Person.new.respond_to?(:readable?).should be_true
  end
        
  it "should define a 'writable?' instance method" do
    Person.new.respond_to?(:writable?).should be_true
  end
              
  it "should define a 'displayable?' instance method" do
    Person.new.respond_to?(:displayable?).should be_true
  end
  
  
  it "should not raise when DataMapper::Is::Protectable.raise_security_error!(:access, :foo) is called" do
    lambda { DataMapper::Is::Protectable.raise_security_error!(:access, :foo) }.should_not raise_error
  end
        
  it "should raise when DataMapper::Is::Protectable.raise_security_error!(:invalid, :permission) is called" do
    lambda { DataMapper::Is::Protectable.raise_security_error!(:invalid, :permission) }.should raise_error(
      DataMapper::Is::Protectable::InvalidPermission
    )
  end
  
end
  
describe "every extended protectable", :shared => true do
  
  it "should define a 'always_let' class method" do
    Person.respond_to?(:always_let).should be_true
  end
  
  it "should define a 'always_deny' class method" do
    Person.respond_to?(:always_deny).should be_true
  end
        
  it "should define a 'never_let' class method" do
    Person.respond_to?(:never_let).should be_true
  end
  
  it "should define a 'never_deny' class method" do
    Person.respond_to?(:never_deny).should be_true
  end

end
    
describe "every not extended protectable", :shared => true do
  
  it "should not define a 'always_let' class method" do
    Person.respond_to?(:always_let).should be_false
  end
  
  it "should not define a 'always_deny' class method" do
    Person.respond_to?(:always_deny).should be_false
  end
        
  it "should not define a 'never_let' class method" do
    Person.respond_to?(:never_let).should be_false
  end
  
  it "should not define a 'never_deny' class method" do
    Person.respond_to?(:never_deny).should be_false
  end

end
      
describe "default permissions are installed", :shared => true do

  it "should enforce default permissions" do
    
    # -------------------------------------------------------
    #   let :read,  :id
    #   let :write, [ :id, :created_at ], :if => :new_record?
    #   let :write, [ :updated_at ]
    # -------------------------------------------------------
    
    # test new record
    lambda { @p.id                    }.should_not raise_error
    lambda { @p.id = 666              }.should_not raise_error
    lambda { @p.created_at = Time.now }.should_not raise_error
    lambda { @p.updated_at = Time.now }.should_not raise_error
    
    @p.save
    
    # test existing record
    lambda { @p.id                    }.should_not raise_error
    lambda { @p.updated_at = Time.now }.should_not raise_error
    
    lambda { @p.id = 666              }.should raise_error(DataMapper::Is::Protectable::IllegalWriteAccess)
    lambda { @p.created_at = Time.now }.should raise_error(DataMapper::Is::Protectable::IllegalWriteAccess)
    
  end

end
    
describe "default permissions are not installed", :shared => true do

  it "should not enforce default permissions" do
    
    # test new record
    lambda { @p.id                    }.should_not raise_error
    lambda { @p.id = 666              }.should_not raise_error
    lambda { @p.created_at = Time.now }.should_not raise_error
    lambda { @p.updated_at = Time.now }.should_not raise_error
    
    @p.save
    
    # test existing record
    lambda { @p.id                    }.should_not raise_error
    lambda { @p.id = 666              }.should_not raise_error
    lambda { @p.created_at = Time.now }.should_not raise_error
    lambda { @p.updated_at = Time.now }.should_not raise_error
    
  end

end

# -----------------------------------------------------------------------------------------------

describe "read access on firstname is granted", :shared => true do
  
  it "should grant read access on firstname" do
    lambda { @p.firstname }.should_not raise_error
  end
  
end


describe "write access on firstname is granted", :shared => true do
    
  it "should grant write access on firstname" do
    lambda { @p.firstname = "snu" }.should_not raise_error
  end
  
end

describe "read and write access on firstname is granted", :shared => true do
  
  it_should_behave_like "read access on firstname is granted"
  it_should_behave_like "write access on firstname is granted"
  
end

# -----------------------------------------------------------------------------------------------

describe "read access on firstname is denied", :shared => true do
  
  it "should deny read access on firstname" do
    lambda { @p.firstname }.should raise_error(DataMapper::Is::Protectable::IllegalReadAccess)
  end
  
end

describe "write access on firstname is denied", :shared => true do
    
  it "should deny write access on firstname" do
    lambda { @p.firstname = "snu" }.should raise_error(DataMapper::Is::Protectable::IllegalWriteAccess)
  end
  
end

describe "read and write access on firstname is denied", :shared => true do
  
  it_should_behave_like "read access on firstname is denied"
  it_should_behave_like "write access on firstname is denied"
  
end

# -----------------------------------------------------------------------------------------------

describe "read access on lastname is granted", :shared => true do
  
  it "should grant read access on lastname" do
    lambda { @p.lastname  }.should_not raise_error
  end
  
end

describe "write access on lastname is granted", :shared => true do
    
  it "should grant write access on lastname" do
    lambda { @p.lastname = "snu"  }.should_not raise_error
  end
  
end

describe "read and write access on lastname is granted", :shared => true do
  
  it_should_behave_like "read access on lastname is granted"
  it_should_behave_like "write access on lastname is granted"
  
end

# -----------------------------------------------------------------------------------------------

describe "read access on lastname is denied", :shared => true do
  
  it "should deny read access on lastname" do
    lambda { @p.lastname }.should raise_error(DataMapper::Is::Protectable::IllegalReadAccess)
  end
  
end

describe "write access on lastname is denied", :shared => true do
    
  it "should deny write access on lastname" do
    lambda { @p.lastname = "snu" }.should raise_error(DataMapper::Is::Protectable::IllegalWriteAccess)
  end
  
end

describe "read and write access on lastname is denied", :shared => true do
  
  it_should_behave_like "read access on lastname is denied"
  it_should_behave_like "write access on lastname is denied"
  
end

# -----------------------------------------------------------------------------------------------


describe "read access on all properties is granted", :shared => true do
  
  it_should_behave_like "read access on firstname is granted"
  it_should_behave_like "read access on lastname is granted"
  
end

describe "write access on all properties is granted", :shared => true do
    
  it_should_behave_like "write access on firstname is granted"
  it_should_behave_like "write access on lastname is granted"
  
end

describe "read and write access on all properties is granted", :shared => true do
  
  it_should_behave_like "read access on all properties is granted"
  it_should_behave_like "write access on all properties is granted"
  
end

# -----------------------------------------------------------------------------------------------


describe "read access on all properties is denied", :shared => true do
  
  it_should_behave_like "read access on firstname is denied"
  it_should_behave_like "read access on lastname is denied"
  
end

describe "write access on all properties is denied", :shared => true do
    
  it_should_behave_like "write access on firstname is denied"
  it_should_behave_like "write access on lastname is denied"
  
end

describe "read and write access on all properties is denied", :shared => true do
  
  it_should_behave_like "read access on all properties is denied"
  it_should_behave_like "write access on all properties is denied"
  
end

# -----------------------------------------------------------------------------------------------
