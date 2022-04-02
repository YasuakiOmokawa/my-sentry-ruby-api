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

class Foo
  def foo() "foo" end
  def bar() "bar" end
  def baz() "baz" end
end

# 任意のキーとメソッドの関係をハッシュに保持しておく
# レシーバの情報がここにはないことに注意
methods = {1 => Foo.instance_method(:foo),
           2 => Foo.instance_method(:bar),
           3 => Foo.instance_method(:baz)}

# キーを使って関連するメソッドを呼び出す
# レシーバは任意(Foo クラスのインスタンスでなければならない)
p methods[1].bind(Foo.new).call      # => "foo"
p methods[2].bind(Foo.new).call      # => "bar"
p methods[3].bind(Foo.new).call      # => "baz"


class Sample
  def method_missing(name, *args)
    if name =~ /^to_*/
      [name, *args] # => [:to_sample, "sample args1", "sample args2"]
      # return
    else
      super
    end
  end

  def respond_to_missing?(sym, include_private)
    (sym =~ /^to_*/) ? true : super
  end
end

s = Sample.new
s.to_sample("sample args1", "sample args2")
s.respond_to?(:to_sample)  # => true
s.respond_to?(:sample)    # => false
