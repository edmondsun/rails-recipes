class Registration < ApplicationRecord
  # STATUS = ["pending", "confirmed"]
  STATUS = ["pending", "confirmed", "cancalled"]
  validates_inclusion_of :status, :in => STATUS
  validates_presence_of :status, :ticket_id

  belongs_to :event
  belongs_to :ticket

  belongs_to :user, :optional => true

  before_validation :generate_uuid, :on => :create
  # validates_presence_of :name, :email, :cellphone, :bio

  attr_accessor :current_step
  validates_presence_of :name, :email, :cellphone, :if => :should_validate_basic_data?
  validates_presence_of :name, :email, :cellphone, :bio, :if => :should_validate_all_data?
  validate :check_event_status, :on => :create

  scope :by_status, ->(s){ where( :status => s ) }
  scope :by_ticket, ->(t){ where( :ticket_id => t ) }

  has_paper_trail


  def to_param
    self.uuid
  end

  protected

  def generate_uuid
    self.uuid = SecureRandom.uuid
  end

  def should_validate_basic_data?
    current_step == 2  # 只有做到第二步需要验证
  end

  def should_validate_all_data?
    current_step == 3 || status == "confirmed"  # 做到第三步，或最后状态是 confirmed 时需要验证
  end

  def check_event_status
    if self.event.status == "draft"
      errors.add(:base, "活動尚未開放報名")
    end
  end
end
