require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

if HAS_SQLITE3 || HAS_MYSQL || HAS_POSTGRES
  
  module Support

    # TODO inspect why this is necessary
    # clean model environments after each example run
    def unload_models(*models)
      models.each do |m|
        model = m.to_s.camel_case
        Object.send(:remove_const, model) if Object.const_defined?(model)
      end
    end
    
    alias :unload_model :unload_models

  end
  
  describe DataMapper::Is::Protectable do
    
    include Support
    
    # --------------------------------------------------------------------------------------------------
    # --------------------------------------------------------------------------------------------------
  
    describe "every protectable", :shared => true do

      it "should define a 'let' class method" do
        Person.respond_to?(:let).should be_true
      end
      
      it "should define a 'deny' class method" do
        Person.respond_to?(:deny).should be_true
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
      
            
      it "should define a 'displayable?' class method" do
        Person.respond_to?(:displayable?).should be_true
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

    end
    
    describe "every protectable with default permissions", :shared => true do

      it "should enforce default permissions" do
        
        # # Always allow to read the id
        # let :read, :id
        # # These shouldn't change after the first save.
        # let :write, [ :id, :created_at ], :if => :new_record?
        # # These can always change.
        # let :write, [ :updated_at ]
        
        p = Person.new
        
        # test new record
        lambda { p.id                    }.should_not raise_error
        lambda { p.id = 666              }.should_not raise_error
        lambda { p.created_at = Time.now }.should_not raise_error
        lambda { p.updated_at = Time.now }.should_not raise_error
        
        p.save
        
        # test existing record
        lambda { p.id                    }.should_not raise_error
        lambda { p.updated_at = Time.now }.should_not raise_error
        
        new_created_at = DateTime.new
        
        lambda { p.id = 666              }.should raise_error(DataMapper::Is::Protectable::IllegalWriteAccess)
        lambda { p.created_at = Time.now }.should raise_error(DataMapper::Is::Protectable::IllegalWriteAccess)
        
      end
    
    end
        
    describe "every protectable without default permissions", :shared => true do

      it "should not enforce default permissions" do
        
        p = Person.new
        
        time_1 = Time.now
        
        # test new record
        lambda { p.id                    }.should_not raise_error
        lambda { p.id = 666              }.should_not raise_error
        lambda { p.created_at = time_1 }.should_not raise_error
        lambda { p.updated_at = time_1 }.should_not raise_error
        
        p.save
        
        time_2 = Time.now
        
        # test existing record
        lambda { p.id                    }.should_not raise_error
        lambda { p.id = 666              }.should_not raise_error
        lambda { p.created_at = Time.now }.should_not raise_error
        lambda { p.updated_at = Time.now }.should_not raise_error
        
      end

    end
    
    describe "Person.is(:protectable)" do
      
      before do
        
        unload_model :person
        
        class Person

          include DataMapper::Resource
          
          property :id,   Serial
          property :created_at, DateTime
          property :updated_at, DateTime

          is :protectable

        end
        
        Person.auto_migrate!
        
      end
      
      it_should_behave_like "every protectable"
      it_should_behave_like "every protectable with default permissions"
      
    end
    
    describe "Person.is(:protectable, :extended => true)" do
      
      before do
        
        unload_model :person
        
        class Person

          include DataMapper::Resource
          
          property :id,   Serial
          property :created_at, DateTime
          property :updated_at, DateTime

          is :protectable, :extended => true

        end
        
        Person.auto_migrate!
        
      end
      
      it_should_behave_like "every protectable"
      it_should_behave_like "every extended protectable"
      it_should_behave_like "every protectable with default permissions"
      
    end
       
    describe "Person.is(:protectable, :defaults => false)" do
      
      before do
        
        unload_model :person
        
        class Person
          
          include DataMapper::Resource
          
          property :id,   Serial
          property :created_at, DateTime
          property :updated_at, DateTime
          
          is :protectable, :defaults => false
          
        end
        
        Person.auto_migrate!
        
      end
      
      it_should_behave_like "every protectable"
      it_should_behave_like "every protectable without default permissions"
      
    end
           
    describe "let(:write) with default permissions (aka grant write to all properties)" do
      
      before do
        
        unload_model :person
        
        class Person
          
          include DataMapper::Resource
          
          property :id,   Serial
          property :nick, String
          property :name, String
          property :created_at, DateTime
          property :updated_at, DateTime
          
          is :protectable
          
          let :write # TODO should this override default permissions or not? (currently it doesn't)
          
        end
        
        Person.auto_migrate!
        
      end
      
      it_should_behave_like "every protectable"
      it_should_behave_like "every protectable with default permissions"
      
      it "should respec let(:write)" do
        p = Person.new
        lambda { p.nick = "snusnu" }.should_not raise_error
        lambda { p.name = "Martin" }.should_not raise_error
        p.save
        p.nick.should == "snusnu"
        p.name.should == "Martin"
      end
      
    end
    
    describe "'let' with (1..n) properties and either no or Symbol rules" do
      
      before do
        
        unload_model :person
        
        class Person

          include DataMapper::Resource

          property :id,         Serial

          property :nick,       String
          property :firstname,  String
          property :lastname,   String
          property :email,      String    
          property :phone,      String      

          property :mood,       String
          property :shoutbox,   String
          property :pm,         String

          property :birthday,   String
          property :hobbies,    String
          property :status,    String

          property :created_at, DateTime
          property :updated_at, DateTime


          is :protectable

          let :read, :nick                           # would be merged into one
          let :read, [ :firstname, :lastname ]       # splitted only for speccing
          let :read, :pm,                            :if     => :funny?
          let :read, [ :phone, :email ],             :unless => :paranoid?

          let :write, :pm
          let :write, :nick,                         :if     => :funny?
          let :write, [ :phone, :email ],            :unless => :serious?

          let :access, :mood
          let :access, :status,                      :if     => :funny?
          let :access, [ :birthday, :hobbies ],      :unless => :serious?


          # permission checking helpers
          [ :paranoid, :funny, :serious ].each do |mood|
            define_method "#{mood}!" do
              self.mood = "'#{mood}'"
            end
            define_method "#{mood}?" do
              self.mood == "'#{mood}'"
            end
          end

        end
        
        Person.auto_migrate!
        
      end
      
      it_should_behave_like "every protectable"
      it_should_behave_like "every protectable with default permissions"
      
      it "should respect let(:read, :nick)" do
        p = Person.new
        
        lambda { p.nick }.should_not raise_error
        lambda { p.nick }.should_not raise_error
        p.nick.should be_nil
        
        p.save
        p.new_record?.should be_false
        
        lambda { p.nick }.should_not raise_error
        lambda { p.nick }.should_not raise_error
        p.nick.should be_nil
      end
            
      it "should respect let(:read, [ :firstname, :lastname ])" do
        p = Person.new
        
        lambda { p.firstname }.should_not raise_error
        lambda { p.firstname }.should_not raise_error
        lambda { p.lastname  }.should_not raise_error
        lambda { p.lastname  }.should_not raise_error
        p.firstname.should be_nil
        p.lastname.should be_nil
        
        p.save
        p.new_record?.should be_false
        
        lambda { p.firstname }.should_not raise_error
        lambda { p.firstname }.should_not raise_error
        lambda { p.lastname  }.should_not raise_error
        lambda { p.lastname  }.should_not raise_error
        p.firstname.should be_nil
        p.lastname.should be_nil
      end
      
      it "should respect let(:read, :pm, :if => :funny?)" do
        
        # test new records
        
        p = Person.new
        
        p.funny?.should be_false
        lambda { p.pm }.should raise_error(DataMapper::Is::Protectable::IllegalReadAccess)
        
        p.funny!
        p.funny?.should be_true
        lambda { p.pm }.should_not raise_error
        
        # test existing records
        
        p.save
        p.new_record?.should be_false
        
        p.serious!
        p.funny?.should be_false
        lambda { p.pm }.should raise_error(DataMapper::Is::Protectable::IllegalReadAccess)
        
        p.funny!
        p.funny?.should be_true
        lambda { p.pm }.should_not raise_error
      end
            
      it "should respect let(:read, [ :phone, :email ], :unless => :paranoid?)" do
        
        # test new records
        
        p = Person.new
        
        p.paranoid?.should be_false
        lambda { p.phone }.should_not raise_error
        lambda { p.email }.should_not raise_error
        
        p.paranoid!
        p.paranoid?.should be_true
        lambda { p.phone }.should raise_error(DataMapper::Is::Protectable::IllegalReadAccess)
        lambda { p.email }.should raise_error(DataMapper::Is::Protectable::IllegalReadAccess)
        
        # test existing records
        
        p.save
        p.new_record?.should be_false
        
        p.serious!
        p.paranoid?.should be_false
        lambda { p.phone }.should_not raise_error
        lambda { p.email }.should_not raise_error
        
        p.paranoid!
        p.paranoid?.should be_true
        lambda { p.phone }.should raise_error(DataMapper::Is::Protectable::IllegalReadAccess)
        lambda { p.email }.should raise_error(DataMapper::Is::Protectable::IllegalReadAccess)
      end
    
      it "should respect let(:write, :pm)" do
        
        # test new records
        
        p = Person.new
        
        lambda { p.pm = "how are you?" }.should_not raise_error
        
        # test existing records
        
        p.save
        p.new_record?.should be_false
        
        lambda { p.pm = "how are you?" }.should_not raise_error
        
        p.save
        lambda { p.pm }.should raise_error(DataMapper::Is::Protectable::IllegalReadAccess)
        
        p.funny!
        p.funny?.should be_true
        lambda { p.pm }.should_not raise_error
        p.pm.should == "how are you?"
      end
      
      it "should respect let(:write, :nick, :if => :funny?)" do
        
        # test new records
        
        p = Person.new
        
        p.funny?.should be_false
        lambda { p.nick = "snusnu" }.should raise_error(DataMapper::Is::Protectable::IllegalWriteAccess)
        p.nick.should be_nil
        
        p.funny!
        p.funny?.should be_true
        lambda { p.nick = "snusnu" }.should_not raise_error
        p.nick.should == "snusnu"
        
        # test existing records
        
        p.save
        p.new_record?.should be_false
        
        p.serious!
        p.funny?.should be_false
        lambda { p.nick = "slurms" }.should raise_error(DataMapper::Is::Protectable::IllegalWriteAccess)
        p.nick.should == "snusnu"
        
        p.funny!
        p.funny?.should be_true
        lambda { p.nick = "slurms" }.should_not raise_error
        
        p.save
        p.nick.should == "slurms"
      end
      
      it "should respect let(:write, [ :phone, :email ], :unless => :serious?)" do
        
        # test new records
        
        p = Person.new
        
        p.serious?.should be_false
        lambda { p.phone = "555 555"           }.should_not raise_error
        lambda { p.email = "snusnu@snusnu.com" }.should_not raise_error
        p.phone.should == "555 555"
        p.email.should == "snusnu@snusnu.com"
        
        p.serious!
        p.serious?.should be_true
        lambda { p.phone = "666 666"          }.should raise_error(DataMapper::Is::Protectable::IllegalWriteAccess)
        lambda { p.email = "snusnu@snusnu.org"}.should raise_error(DataMapper::Is::Protectable::IllegalWriteAccess)
        p.phone.should == "555 555"
        p.email.should == "snusnu@snusnu.com"
        
        # test existing records
        
        p.save
        p.new_record?.should be_false
        
        p.funny!
        p.serious?.should be_false
        lambda { p.phone = "666 666"           }.should_not raise_error
        lambda { p.email = "snusnu@snusnu.org" }.should_not raise_error
        p.phone.should == "666 666"
        p.email.should == "snusnu@snusnu.org"
        
        p.serious!
        p.serious?.should be_true
        lambda { p.phone = "555 555"          }.should raise_error(DataMapper::Is::Protectable::IllegalWriteAccess)
        lambda { p.email = "snusnu@snusnu.com"}.should raise_error(DataMapper::Is::Protectable::IllegalWriteAccess)
        p.phone.should == "666 666"
        p.email.should == "snusnu@snusnu.org"
        
        p.save
        p.phone.should == "666 666"
        p.email.should == "snusnu@snusnu.org"
      end
      
      it "should respect let(:access, :shoutbox)" do
        
        # test new records
        
        p = Person.new
        
        lambda { p.shoutbox                  }.should_not raise_error
        p.shoutbox.should be_nil
        lambda { p.shoutbox = "how are you?" }.should_not raise_error
        p.shoutbox.should == "how are you?"
        
        # test existing records
        
        p.save
        p.new_record?.should be_false
        
        lambda { p.shoutbox                  }.should_not raise_error
        p.shoutbox.should == "how are you?"
        lambda { p.shoutbox = "fine thanks!" }.should_not raise_error
        p.shoutbox.should == "fine thanks!"
        
        p.save
        p.shoutbox.should == "fine thanks!"
      end
      
      it "should respect let(:access, :status, :if => :funny?)" do
        
        # test new records
        
        p = Person.new
        
        p.funny?.should be_false
        lambda { p.status            }.should raise_error(DataMapper::Is::Protectable::IllegalReadAccess)
        lambda { p.status = "online" }.should raise_error(DataMapper::Is::Protectable::IllegalWriteAccess)
        
        p.funny!
        p.funny?.should be_true
        lambda { p.status            }.should_not raise_error
        p.status.should be_nil
        lambda { p.status = "online" }.should_not raise_error
        p.status.should == "online"
        
        # test existing records
        
        p.save
        p.new_record?.should be_false
        
        p.paranoid!
        p.funny?.should be_false
        lambda { p.status          }.should raise_error(DataMapper::Is::Protectable::IllegalReadAccess)
        lambda { p.status = "offline" }.should raise_error(DataMapper::Is::Protectable::IllegalWriteAccess)
        
        p.funny!
        p.funny?.should be_true
        lambda { p.status          }.should_not raise_error
        p.status.should == "online"
        lambda { p.status = "offline" }.should_not raise_error
        p.status.should == "offline"
        
        p.save
        p.status.should == "offline"
      end
      
      
      it "should respect let(:access,  [ :birthday, :hobbies ], :unless => :serious?)" do
        
        # test new records
        
        p = Person.new
        
        p.serious?.should be_false
        lambda { p.birthday      }.should_not raise_error
        lambda { p.hobbies       }.should_not raise_error
        p.birthday.should be_nil
        p.hobbies.should be_nil
        
        lambda { p.birthday = "010101"      }.should_not raise_error
        lambda { p.hobbies  = "tabletennis" }.should_not raise_error
        p.birthday.should == "010101"
        p.hobbies.should  == "tabletennis"
        
        p.serious!
        p.serious?.should be_true
        lambda { p.birthday      }.should raise_error(DataMapper::Is::Protectable::IllegalReadAccess)
        lambda { p.hobbies       }.should raise_error(DataMapper::Is::Protectable::IllegalReadAccess)
        
        lambda { p.birthday = "010101"      }.should raise_error(DataMapper::Is::Protectable::IllegalWriteAccess)
        lambda { p.hobbies  = "tabletennis" }.should raise_error(DataMapper::Is::Protectable::IllegalWriteAccess)
        
        p.funny!
        p.funny?.should be_true
        p.birthday.should == "010101"
        p.hobbies.should  == "tabletennis"
        
        
        # test existing records
        
        p.save
        p.new_record?.should be_false
        
        p.serious?.should be_false
        lambda { p.birthday      }.should_not raise_error
        lambda { p.hobbies       }.should_not raise_error
        p.birthday.should == "010101"
        p.hobbies.should  == "tabletennis"
        
        lambda { p.birthday = "020202"   }.should_not raise_error
        lambda { p.hobbies  = "swimming" }.should_not raise_error
        p.birthday.should == "020202"
        p.hobbies.should  == "swimming"
        
        p.serious!
        p.serious?.should be_true
        lambda { p.birthday      }.should raise_error(DataMapper::Is::Protectable::IllegalReadAccess)
        lambda { p.hobbies       }.should raise_error(DataMapper::Is::Protectable::IllegalReadAccess)
        
        lambda { p.birthday = "010101"      }.should raise_error(DataMapper::Is::Protectable::IllegalWriteAccess)
        lambda { p.hobbies  = "tabletennis" }.should raise_error(DataMapper::Is::Protectable::IllegalWriteAccess)
        
        p.funny!
        p.funny?.should be_true
        p.birthday.should == "020202"
        p.hobbies.should  == "swimming"
      end
    end
  
  end
  
end