# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password
  rolify
  belongs_to :organization
  has_many :identities, dependent: :destroy
  has_many :campaigns, dependent: :destroy
  after_create :assign_default_role
  # after_create :seed_data

  # validates :name,
  #   presence: true,
  #   length: { maximum: 75 }
  validates :username,
            presence: true,
            uniqueness: { case_sensitive: false },
            length: { minimum: 6, maximum: 256 },
            format: { with: URI::MailTo::EMAIL_REGEXP }

  #
  # https://sourcey.com/articles/rails-omniauth-using-devise-with-twitter-facebook-and-linkedin
  # JML - 2020-09-03
  #
  def self.find_for_oauth(auth, signed_in_resource = nil)
    # Get the identity and user if they exist
    identity = Identity.find_for_oauth(auth)

    # If a signed_in_resource is provided it always overrides the existing user
    # to prevent the identity being locked with accidentally created accounts.
    # Note that this may leave zombie accounts (with no associated identity) which
    # can be cleaned up at a later date.
    user = signed_in_resource || identity.user

    # Create the user if needed
    if user.nil?

      # Get the existing user by email if the provider gives us a verified email.
      # If no verified email was provided we assign a temporary email and ask the
      # user to verify it on the next step via UsersController.finish_signup
      # email_is_verified = auth.info.email && (auth.info.verified || auth.info.verified_email)
      #
      # Google uses `auth.info.email_verified`
      #  email_is_verified = auth.info.email && (auth.info.verified || auth.info.email_verified)
      #  email = auth.info.email if email_is_verified
      username = auth.info.email
      user = User.where(username: username).first if username

      # Create the user if it's a new registration
      if user.nil?
        org = Organization.create(name: 'My Organization')
        user = User.new(
          name: auth.info.name,
          username: username.downcase,
          password_digest: BCrypt::Password.create(SecureRandom.hex(20)),
          organization: org
        )
        # user.skip_confirmation!
        user.save!
      end
    end

    # Associate the identity with the user if needed
    if identity.user != user
      identity.user = user
      identity.save!
    end

    user
  end

  def get_nav_paths
    paths = [
      {
        path: '/campaigns',
        name: 'Campaigns',
        num: Campaign.all.count.to_s
      },
      {
        path: '/profiles',
        name: 'Profiles',
        num: Profile.all.count.to_s
      },
      {
        path: '/controls',
        name: 'Controls',
        num: Control.all.count.to_s
      },
      {
        path: '/sources',
        name: 'Sources',
        num: Source.all.count.to_s
      }
    ]

    if is_admin?
      paths.push({
                   path: '/admin',
                   name: 'Admin'
                 })
    end

    paths
  end

  private

  # Add :user role
  #
  def assign_default_role
    add_role(:user) if roles.blank?
    add_role(:admin) if Rails.application.config.authorized_for_admin_role.include?(username)
  end

  # Seed some sample data
  #
  def seed_data
    # TODO: move this to a background job
    # org = Organization.create(name: 'My Organization')

    Campaign::SEED.each { |c| org.campaigns.find_or_create_by(c.merge({ user: self })) }
  end
end
