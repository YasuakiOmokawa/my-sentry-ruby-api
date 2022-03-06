# ハッシュを返却するメソッドから、不要なキーを取り除く
def get_hash
  {
    'hoge' => 'fuga',
    'piyo' => 'puyo',
  }
end
EXCLUDES = %w[hoge]

def m1
  res = get_hash
  EXCLUDES.each { |k| res.delete(k) }
  p res
end

def m2
  res = EXCLUDES.each { |k| get_hash.delete(k) }
  p res
end

def m3
  get_hash.reduce({}) do |sum, (k, v)|
    EXCLUDES.include?(k) ? sum : sum[k] = v
    sum
  end
end

@hoge = 'hoge'
def defined_check
  defined?(@hoge) ? @hoge : nil
  # return defined?(@hoge) ? @hoge : nil
end
defined_check

def m4
  get_hash.except(*EXCLUDES)
end

module Hoge
  def self.included(base)
    base.extend(ClassMethods)
  end

  def self.receiver_is_self
    'receiver is self'
  end

  module ClassMethods
    def c_method1
      'class method'
    end
  end
end

class Fuga
  include Hoge
end

p Hoge.receiver_is_self
p Fuga.c_method1
