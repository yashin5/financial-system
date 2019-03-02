defmodule FinancialSystem do
  # TODO

  @moduledoc false

  alias FinancialSystem.Account, as: Account
  alias FinancialSystem.SplitList, as: SplitList

  def create_user(name, email, currency, initial_value) do
    %Account{name: name, email: email, currency: String.upcase(currency), value: initial_value}
  end

  def deposit(%Account{value: value_to, currency: currency_to} = account_to, currency_from, deposit_amount) when deposit_amount > 0 do
    add_value(account_to, value_to, currency_from, currency_to, deposit_amount)
  end

  def transfer(
        %Account{email: email_from, value: value_from, currency: currency_from} = account_from,
        %Account{email: email_to, value: value_to, currency: currency_to} = account_to,
        transfer_amount
      )
      when email_from != email_to and value_from >= transfer_amount and transfer_amount > 0 do
      subtracts_value(account_from, value_from, transfer_amount) 

      add_value(account_to, value_to, currency_from, currency_to, transfer_amount)
  end

  def split(%Account{email: email_from, value: value_from, currency: currency_from} = account_from, list_to, split_amount)
    when value_from >= split_amount and split_amount > 0 do
    if list_to_ok?(email_from, list_to) do
      raise(ArgumentError, message: "Cannot split from one account to the same.")
    else
      subtracts_value(account_from, value_from, split_amount)  
      map_split(list_to, split_amount, currency_from)
    end
  end

  def do_split(account_to, split_amount, currency_from) do
    account_to
    |> Enum.map(fn %SplitList{
      account: %Account{value: value_to, currency: currency_to} = account,
      percent: percent} ->
  
      split_to = percent / 100 * split_amount
  
      add_value(account, value_to, currency_from, currency_to, split_to)
    end)
  end

  def map_split(account_to, split_amount, currency_from) when split_amount > 0 do
    if percent_ok?(account_to) do 
      account_ok?(account_to) 
      |> do_split(split_amount, currency_from)
    else
      raise(ArgumentError, message: "The total percent must be 100")
    end
  end

  def list_to_ok?(email_from, list_to) do 
    Enum.map(list_to, fn %SplitList{account: %Account{email: email_to}} -> email_from == email_to end)
    |> Enum.member?(true)
  end

  def account_ok?(account_to) do
    account_to
    |> Enum.reduce(%{}, fn %SplitList{
                            account: %Account{email: email}} = sp,
                          acc ->
      Map.update(acc, email, sp, fn acc -> %{acc | percent: acc.percent + sp.percent} end)
    end)
    |> Enum.map(fn {_, res} -> res end)
  end

  def percent_ok?(account_to) do
    account_to
    |> Enum.map(fn %SplitList{percent: percent} ->
      percent
    end)
    |> Enum.sum() == 100
  end

  def subtracts_value(account_from, value_from, action_amount) do
    new_value_from = value_from - action_amount

    %Account{account_from | value: new_value_from}    
  end

  def add_value(account_to, value_to, currency_to, currency_from, action_amount) do
    balance_value = convert(action_amount, currency_to, currency_from)

    new_value_to = balance_value + value_to
  
    %Account{account_to | value: new_value_to}
  end

  def currency_rate() do
    # Getting currency list
    case File.read("currency_rate.json") do
      {:ok, body} -> Poison.decode!(body)
      {:error, _reason} -> {:error}
    end
  end
  
  def convert(value, code, account_code) do
    code = String.upcase(code)
    account_code = String.upcase(account_code)
    account_code = currency_rate()["quotes"]["USD#{account_code}"]

    if Map.has_key?(currency_rate()["quotes"], "USD#{code}") &&
        value > 0 do
      cond do
        code == "USD" -> convert_to_USD(account_code, value)
        code != "USD" -> convert_to_others(code, value, account_code)
      end
    else
      raise(ArgumentError, message: "\ninvalid currency or value\n")
    end
  end
  
  def convert_to_USD(account_code, value) do
    account_code * value
  end

  def convert_to_others(code, value, account_code) do
    value / currency_rate()["quotes"]["USD#{code}"] * account_code
  end
end