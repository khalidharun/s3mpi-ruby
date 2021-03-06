require 'json'
require 's3mpi/format'
require 's3mpi/s3'

module S3MPI
  class Interface
    include Format
    include S3

    # Return S3 bucket under use.
    #
    # @return [AWS::S3::Bucket]
    attr_reader :bucket

    # Return S3 path under use.
    #
    # @return [String]
    attr_reader :path
    
    # Create a new S3MPI object that responds to #read and #store.
    #
    # @return [S3MPI::Interface]
    #
    # @api public
    def initialize _bucket, path = ''
      @bucket = _bucket
      @path   = path 
    end

    # Store a Ruby object in an S3 bucket.
    # 
    # @param [Object] obj
    #    Any JSON-serializable Ruby object (usually a hash or array).
    # @param [String] key
    #    The key under which to save the object in the S3 bucket.
    # @param [Integer] try
    #    The number of times to attempt to store the object.
    def store(obj, key = SecureRandom.uuid, try = 1)
      s3_object(key).write(obj.to_json)
    rescue 
      (try -= 1) > 0 ? retry : raise
    end

    # Read a JSON-serialized Ruby object from an S3 bucket.
    # 
    # @param [String] key
    #    The key under which to save the object in the S3 bucket.
    def read key = nil
      parse_json_allowing_quirks_mode s3_object(key).read
    rescue AWS::S3::Errors::NoSuchKey
      nil
    end

    # Check whether a key exists for this MPI interface.
    # 
    # @param [String] key
    #    The key under which to save the object in the S3 bucket.
    #    
    # @return [TrueClass,FalseClass]
    def exists?(key)
      s3_object(key).exists?
    end

    # Fetch the S3 object as an AWS::S3::S3Object.
    # 
    # @param [String] name
    #    The key under which to save the object in the S3 bucket.
    #    
    # @return [AWS::S3::S3Object]
    def object(key)
      AWS::S3::S3Object.new(bucket, "#{@path}#{key}")
    end

    def bucket
      @_bucket ||= parse_bucket @bucket
    end

  end
end

    
