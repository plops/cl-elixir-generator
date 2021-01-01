defmodule KV.RegistryTest do
  use ExUnit.Case, async: true

  setup do
    registry = start_supervised!(KV.Registry)
    %{:registry => registry}
  end

  test "spawn buckets", %{:registry => registry} do
    assert(:error == KV.Registry.lookup(registry, "shopping"))
    KV.Registry.create(registry, "shopping")
    assert({:ok, bucket} = KV.Registry.lookup(registry, "shopping"))
    KV.Bucket.put(bucket, "milk", 1)
    assert(1 == KV.Bucket.get(bucket, "milk"))
  end
end
