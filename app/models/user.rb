class User < ActiveRecord::Base
  has_many :password_resets, :order => 'created_at DESC', :dependent => :destroy
  before_create :make_admin_if_first_user

  acts_as_authentic do |c|
    c.validate_email_field = false
    c.openid_optional_fields = [:fullname, :email, "http://axschema.org/contant/email"]
  end

  class << self
    def find_by_openid_identifier(identifier)
      first(:conditions => { :openid_identifier => identifier }) ||
        new(:openid_identifier => identifier)
    end
  end

  def map_openid_registration(sreg)
    self.email = sreg["email"] if email.blank?
    self.name  = sreg["fullname"] if name.blank?
  end
  
  def confirm_password_reset
    reset_perishable_token!
    Notification.deliver_password_reset_confirmation(self)
  end
  
  def password_reset_confirmed(confirming_ip)
    return false if password_resets.empty?
    # ok to just confirm first in collection due to :order set in has_many
    password_resets.first.confirm(confirming_ip)
  end

  private
    def make_admin_if_first_user
      self.is_admin = true if User.count == 0
    end
end
