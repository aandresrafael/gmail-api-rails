require 'encryption'

class PasswordKey
  attr_reader :passphrase

  def initialize(passphrase)
    @passphrase = passphrase
  end

  def encrypt(plaintext)
    ::Encryption.encrypt(plaintext, @passphrase)
  end

  def decrypt(ciphertext)
    ::Encryption.decrypt(ciphertext, @passphrase)
  end

  private

  HARDCODED_KEY = PasswordKey.new('FouG9jurUi5riv2nGeeD2aomOhbeic5a')
end
