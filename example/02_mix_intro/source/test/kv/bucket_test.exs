defmodule KV.BucketTest do
  use ExUnit.Case, async: true

  test "stores values by key" do
    {:ok, bucket} = KV.Bucket.start_link([])
    assert(nil == KV.Bucket.get(bucket, "milk"))
    KV.Bucket.put(bucket, "milk", 3)
    assert(3 == KV.Bucket.get(bucket, "milk"))
  end
end
