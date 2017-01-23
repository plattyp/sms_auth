class PhoneNumberUtils
  def self.cleanup_phone_number(phone_num)
    !phone_num.nil? ? phone_num.gsub(/\D/, '') : nil
  end
end
