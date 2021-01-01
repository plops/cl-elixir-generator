defmodule KV.BucketTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, bucket} = KV.Bucket.start_link([])
    %{:bucket => bucket}
  end

  test "stores values by key", %{:bucket => bucket} do
    assert(nil == KV.Bucket.get(bucket, "milk"))
    KV.Bucket.put(bucket, "milk", 3)
    assert(3 == KV.Bucket.get(bucket, "milk"))
  end
end
