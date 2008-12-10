require 'digest/sha1'
class User < ActiveRecord::Base
  
  validates_presence_of :name, :point_value
  validates_uniqueness_of :name, :case_sensitive => false
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  
  has_many :efforts
  has_and_belongs_to_many :roles
  
  
  # ----- Authenticated System meta-method calls. ---------
  
  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates_presence_of     :login, :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :login, :email, :case_sensitive => false
  before_save :encrypt_password
  
  
  # ----NB!!!  - Remember to add attributes here that you want to allow mass association for.
  # 
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :password_confirmation, :name, :point_value

  
  
  
  
  
  def time_worked(day = Time.today)
    result = Effort.find_by_sql([ "SELECT sum(duration) as duration FROM efforts 
                                 WHERE user_id = ? 
                                 AND start >= ? 
                                 AND start < ?
                                 AND finished = 't'", 
                                 self.id, day.to_date, day.to_date+1 ])
    result[0][:duration] || 0
  end
  
  def daily_efforts(day = Time.today)
    self.efforts.find(:all, :conditions => ["start >= ? AND start < ? AND finished = 't'", day.to_date, day.to_date+1], :order => :start )
  end
  
  def assign_effort(attr={})
    effort = Effort.new(attr.merge(:user => self))
    return Effort.create_with_conflict_resolution(effort)
  end
  
  def unfinished_effort
    self.efforts.find(:first, :conditions => {:finished => false})
  end
  
  def start_effort(attr={})
    if attr[:start].blank?
      attr[:start] = Time.now
    end
    effort = Effort.create!(attr.merge(:finished => false, :user => self))
    self.efforts.reload
    return effort
  end
  
  def finish_effort(stop_time = Time.now)
    result = self.unfinished_effort.finish(stop_time)
    self.efforts.reload
    return result
  end
  
  def has_permission?(controller, action)
    return self.roles.detect{ |role|
      role.rights.detect{ |right|
        right.action == action.to_s && right.controller == controller.to_s
      }
    }
  end
  
  
  # ------- Authenticated System Methods -------------

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end

  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end
      
    def password_required?
      crypted_password.blank? || !password.blank?
    end
    
    
end
