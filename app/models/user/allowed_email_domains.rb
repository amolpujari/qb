class User < ActiveRecord::Base
  def self.apply_allowed_email_domains_restriction
    config_allowed_email_domains = CONFIG[:allowed_email_domains].to_s.strip rescue ''
    return if config_allowed_email_domains.blank?
    
    domains = eval "\"#{config_allowed_email_domains}\""
    domains = domains.gsub(',','","').delete(' ')
    domains = eval "[\"#{domains}\"]"
    with_option = eval "/@(#{domains.join('|')})$/i".gsub('.','\.')

    validates_format_of :email, :with => with_option,
      :message => "from only #{CONFIG[:allowed_email_domains]} allowed"
  end

  apply_allowed_email_domains_restriction
end
