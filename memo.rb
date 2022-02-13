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
