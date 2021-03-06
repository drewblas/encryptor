require 'openssl'
require 'encryptor/string'

# A simple wrapper for the standard OpenSSL library
module Encryptor
  # The default options to use when calling the <tt>encrypt</tt> and <tt>decrypt</tt> methods
  #
  # Defaults to { :algorithm => 'aes-256-cbc' }
  #
  # Run 'openssl list-cipher-commands' in your terminal to view a list all cipher algorithms that are supported on your platform
  def self.default_options
    @default_options ||= { :algorithm => 'aes-256-cbc' }
  end
  
  # Encrypts a <tt>:value</tt> with a specified <tt>:key</tt>
  #
  # Optionally accepts <tt>:iv</tt> and <tt>:algorithm</tt> options
  #
  # Example
  #
  #   encrypted_value = Encryptor.encrypt(:value => 'some string to encrypt', :key => 'some secret key')
  #   # or
  #   encrypted_value = Encryptor.encrypt('some string to encrypt', :key => 'some secret key')
  def self.encrypt(*args)
    crypt :encrypt, *args
  end
  
  # Decrypts a <tt>:value</tt> with a specified <tt>:key</tt>
  #
  # Optionally accepts <tt>:iv</tt> and <tt>:algorithm</tt> options
  #
  # Example
  #
  #   decrypted_value = Encryptor.decrypt(:value => 'some encrypted string', :key => 'some secret key')
  #   # or
  #   decrypted_value = Encryptor.decrypt('some encrypted string', :key => 'some secret key')
  def self.decrypt(*args)
    crypt :decrypt, *args
  end
  
  protected
  
    def self.crypt(cipher_method, *args) #:nodoc:
      options = default_options.merge(:value => args.first).merge(args.last.is_a?(Hash) ? args.last : {})
      cipher = OpenSSL::Cipher::Cipher.new(options[:algorithm])
      cipher.send(cipher_method)
      if options[:iv]
        cipher.key = options[:key]
        cipher.iv = options[:iv]
      else
        cipher.pkcs5_keyivgen(options[:key])
      end
      result = cipher.update(options[:value])
      result << cipher.final
    end
end

String.send :include, Encryptor::String