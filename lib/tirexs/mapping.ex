defmodule Tirexs.Mapping do
  @moduledoc false

  import Tirexs.Mapping.Helpers
  import Tirexs.Helpers
  import Tirexs.ElasticSearch

  @doc false
  defmacro __using__(_) do
    quote do
      import unquote(Tirexs.Mapping), only: [mappings: 1, indexes: 1]
    end
  end

  @doc false
  defmacro mappings([do: block]) do
    mappings =  [properties: extract(block)]
    quote do
      var!(index) = var!(index) ++ [mapping: unquote(mappings)]
    end
  end

  @doc false
  def indexes(options) do
    case options do
      [name, options] ->
        if options[:do] != nil do
          block = options
          options = [type: "object"]
          Dict.put([], to_atom(name), options ++ [properties: extract(block[:do])])
        else
          Dict.put([], to_atom(name), options)
        end
      [name, options, block] ->
        Dict.put([], to_atom(name), options ++ [properties: extract(block[:do])])
    end
  end

  @doc false
  def create_resource(definition, opts) do
    if definition[:type] do
      create_resource_settings(definition, opts)

      url  = "#{definition[:name]}/#{definition[:type]}/_mapping"
      json = to_resource_json(definition)

      put(url, json, opts)
    else
      url  = "#{definition[:name]}/_mapping"
      json = to_resource_json(definition, definition[:name])

      put(url, json, opts)
    end
  end

  @doc false
  def create_resource_settings(definition, opts) do
    unless exist?(definition[:name], opts), do: put(definition[:name], opts)
  end

  @doc false
  def to_resource_json(definition), do: to_resource_json(definition, definition[:type])

  @doc false
  def to_resource_json(definition, type) do
    json_dict = Dict.put([], type, definition[:mapping])
    JSON.encode(json_dict)
  end
end