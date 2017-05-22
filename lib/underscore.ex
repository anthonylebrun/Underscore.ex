defmodule Underscore do
  @moduledoc """
  Re-implementing (most of) the pure collection functions from Underscore.js in Elixir (as a code kata exercise). Requirements: neither the Enum module nor native erlang method implementations may be used and functions must support tail recursion.
  """

  @doc """
  ## Examples
      iex> Underscore.reduce([1, 2, 3], fn(acc, x) -> acc + x end, 4)
      10
      iex> Underscore.reduce([1, 2, 3], fn(acc, x) -> acc + x end)
      6

  """
  def reduce(list, fun, acc \\ nil) do
    do_reduce(list, fun, acc)
  end

  defp do_reduce([], _fun, acc) do
    acc
  end
  defp do_reduce([head | tail], fun, nil) do
    do_reduce(tail, fun, head)
  end
  defp do_reduce([head | tail], fun, acc) do
    do_reduce(tail, fun, fun.(acc, head))
  end

  @doc """
  ## Examples
      iex> Underscore.reverse([1, 2, 3])
      [3, 2, 1]

  """
  def reverse(list) do
    reduce(list, fn(acc, x) -> [x | acc] end, [])
  end

  @doc """
  ## Examples
      iex> Underscore.map([1, 2, 3], fn(x) -> x * x end)
      [1, 4, 9]

  """
  def map(list, fun) do
    do_map(list, fun, [])
  end

  defp do_map(list, fun, acc) do
    list
    |> reduce(fn(acc, x) -> [fun.(x) | acc] end, acc)
    |> reverse
  end

  @doc """
  ## Examples
      iex> Underscore.find([1, 2, 3, 4, 5, 6], fn(x) -> rem(x, 2) == 0 end)
      2

  """
  def find(list, predicate) do
    do_find(list, predicate)
  end
 
  defp do_find([], _predicate) do
    :none
  end
  defp do_find([head | tail], predicate) do
    if predicate.(head) do
      head
    else
      do_find(tail, predicate)
    end
  end

  @doc """
  ## Examples
      iex> Underscore.filter([1, 2, 3, 4, 5, 6], fn(x) -> rem(x, 2) == 0 end)
      [2, 4, 6]

  """
  def filter(list, predicate) do
    reduce(list, fn(acc, x) ->
      if predicate.(x), do: [x | acc], else: acc
    end, []) |> reverse
  end

  @doc """
  ## Examples
      iex> Underscore.where([%{color: "purple", shape: "circle"}, %{color: "red", shape: "triangle"}, %{color: "blue", shape: "circle"}, %{color: "green", shape: "square"}], %{shape: "circle"})
      [%{color: "purple", shape: "circle"}, %{color: "blue", shape: "circle"}]

  """
  def where(list, properties) do
    with filter_props <- MapSet.new(properties) do
      filter(list, fn(x) ->
        MapSet.subset?(filter_props, MapSet.new(x))
      end)
    end
  end

  @doc """
  ## Examples
      iex> Underscore.find_where([%{color: "purple", shape: "circle"}, %{color: "red", shape: "triangle"}, %{color: "blue", shape: "circle"}, %{color: "green", shape: "square"}], %{shape: "circle"})
      %{color: "purple", shape: "circle"}

  """
  def find_where(list, properties) do
    with filter_props <- MapSet.new(properties) do
      find(list, fn(x) ->
        MapSet.subset?(filter_props, MapSet.new(x))
      end)
    end
  end

  @doc """
  ## Examples
      iex> Underscore.reject([1, 2, 3, 4, 5, 6], fn(x) -> rem(x, 2) == 0 end)
      [1, 3, 5]

  """
  def reject(list, predicate) do
    reduce(list, fn(acc, x) ->
      if !predicate.(x), do: [x | acc], else: acc
    end, []) |> reverse
  end

  @doc """
  ## Examples
      iex> Underscore.identity("foo")
      "foo"

  """
  def identity(x), do: x

  @doc """
  ## Examples
      iex> Underscore.every([2, 4, 5], fn(x) -> rem(x, 2) == 0 end)
      false
      iex> Underscore.every([2, 4, 6], fn(x) -> rem(x, 2) == 0 end)
      true
      iex> Underscore.every([false, true, false])
      false

  """
  def every(list, predicate \\ &identity/1) do
    reject(list, predicate) == []
  end

  @doc """
  ## Examples
      iex> Underscore.some([2, 4, 5], fn(x) -> rem(x, 2) == 0 end)
      true
      iex> Underscore.some([2, 4, 6], fn(x) -> rem(x, 2) == 0 end)
      true
      iex> Underscore.some([false, true, false])
      true

  """
  def some(list, predicate \\ &identity/1) do
    find(list, predicate) != :none
  end

  @doc """
  ## Examples
      iex> Underscore.contains([2, 4, 6], 4)
      true
      iex> Underscore.contains([2, 4, 6], 8)
      false

  """
  def contains(list, value) do
    reduce(list, fn(acc, x) ->
      if acc || x == value, do: true, else: false
    end, false)
  end

  @doc """
  ## Examples
      iex> Underscore.pluck([%{color: "purple", shape: "circle"}, %{color: "red", shape: "triangle"}, %{color: "blue", shape: "circle"}, %{color: "green", shape: "square"}], :color)
      ["purple", "red", "blue", "green"]

  """
  def pluck(list, key) do
    map(list, &(Map.get(&1, key)))
  end

  @doc """
  ## Examples
      iex> Underscore.max([1, 100, 10])
      100
      iex> Underscore.max([%{num: 1}, %{num: 100}, %{num: 10}], fn(x) -> x.num end)
      %{num: 100}

  """
  def max(list, fun \\ &identity/1) do
    reduce(list, fn(acc, x) ->
      if fun.(x) > fun.(acc), do: x, else: acc
    end)
  end

  @doc """
  ## Examples
      iex> Underscore.min([100, 1, 10])
      1
      iex> Underscore.min([%{num: 1}, %{num: 100}, %{num: 10}], fn(x) -> x.num end)
      %{num: 1}

  """
  def min(list, fun \\ &identity/1) do
    reduce(list, fn(acc, x) ->
      if fun.(x) < fun.(acc), do: x, else: acc
    end)
  end

  @doc """
  ## Examples
      iex> Underscore.sort([2, 3, 5, 4, 1, 5])
      [1, 2, 3, 4, 5, 5]
      iex> Underscore.sort([2, 3, 5, 4, 1, 5], fn(x) -> -x end)
      [5, 5, 4, 3, 2, 1]

  """
  def sort(list, fun \\ &identity/1) do
    do_sort([], list, fun)
  end
  
  defp do_sort(_sorted = [], _unsorted = [head| tail], fun) do
    do_sort([head], tail, fun)
  end
  defp do_sort(sorted, _unsorted = [], _fun) do
    sorted
  end
  defp do_sort(sorted, _unsorted = [head | tail], fun) do
    sorted
    |> insert(head, fun)
    |> do_sort(tail, fun)
  end

  defp insert(_sorted = [], node, _fun) do
    [node]
  end
  defp insert(_sorted = [min | rest], node, fun) do
    if fun.(min) >= fun.(node) do
      [node | [min | rest]]
    else
      [min | insert(rest, node, fun)]
    end
  end

  @doc """
  ## Examples
      iex> Underscore.group_by([1, 2, 3], fn(x) -> if rem(x, 2) == 0, do: :even, else: :odd end)
      %{even: [2], odd: [1, 3]}

  """
  def group_by(list, fun) do
    reduce(list, fn(acc, x) ->
      Map.update(acc, fun.(x), [x], &(&1 ++ [x]))
    end, %{})
  end

  @doc """
  ## Examples
      iex> Underscore.index_by([1, 2, 3], fn(x) -> x * x end)
      %{1 => 1, 4 => 2, 9 => 3}

  """
  def index_by(list, fun) do
    reduce(list, fn(acc, x) ->
      Map.put(acc, fun.(x), x)
    end, %{})
  end

  @doc """
  ## Examples
      iex> Underscore.size([1, 1, 1, 1])
      4

  """
  def size(list) do
    reduce(list, fn(acc, _x) ->
      acc + 1
    end, 0)
  end

  @doc """
  ## Examples
      iex> Underscore.count_by([1, 2, 3, 4, 5], fn(x) -> if rem(x, 2) == 0, do: :even, else: :odd end)
      %{odd: 3, even: 2}

  """
  def count_by(list, fun) do
    with groups <- group_by(list, fun), keys <- Map.keys(groups) do
      reduce(keys, fn(acc, key) ->
        Map.put(acc, key, size(Map.get(groups, key)))
      end, %{})
    end
  end

  @doc """
  ## Examples
      iex> Underscore.partition([1, 2, 3, 4, 5], fn(x) -> rem(x, 2) != 0 end)
      [[1, 3, 5], [2, 4]]

  """
  def partition(list, predicate) do
    %{true => match, false => rest} = group_by(list, predicate)
    [match, rest]
  end
end
