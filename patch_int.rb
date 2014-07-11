# Mixin for integers to put commas between thousands
module CommaFormatter
  module_function

  public

  def with_commas
    # Work through, finding...
    # Three digit sections, preceded and followed by at least one digit and...
    # Replace with the digits followed by a comma

    to_s.gsub( /(\d)(?=(\d{3})+(?!\d))/, '\\1,' )
  end
end

# Update to Fixnum...
class Fixnum
  include CommaFormatter
end

# ... and Bignum to add commas to a number
class Bignum
  include CommaFormatter
end
