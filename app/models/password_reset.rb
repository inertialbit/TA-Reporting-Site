# == Schema Information
#
# Table name: password_resets
#
#  id            :integer       not null, primary key
#  user_id       :integer       
#  status        :string(100)   
#  requesting_ip :string(30)    
#  confirming_ip :string(30)    
#  sent_to       :string(255)   
#  created_at    :datetime      
#  updated_at    :datetime      
# End Schema

class PasswordReset < ActiveRecord::Base
  
  belongs_to :user
  
  validates_presence_of :sent_to, :status
  
  before_validation :load_user_and_record_status, :on => :create
  after_create :send_confirmation_email
  
  acts_as_stripped :sent_to
  
  private
    def load_user_and_record_status
      return false if sent_to.blank?

      if User.count(:conditions => {:email => sent_to}) > 0
        self.user = User.find_by_email(sent_to)
        self.status = 'pending'
      else
        self.status = 'invalid email'
      end
    end
    
    def send_confirmation_email
      unless self.user_id.nil?
        self.user.confirm_password_reset
        self.status = 'email sent'
        self.save
      end
    end
  protected
  public
    def confirm(client_ip)
      update_attributes({
        :confirming_ip => client_ip,
        :status => 'confirmed'
      })
    end
end
