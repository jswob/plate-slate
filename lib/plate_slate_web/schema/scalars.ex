defmodule PlateSlateWeb.Schema.Scalars do
	use Absinthe.Schema.Notation

	@desc "The custom scalar type for decimals"
	scalar :decimal do
		parse fn
			%{value: value}, _ ->
				{decimal, _} = Decimal.parse(value)
				{:ok, decimal}
			 _, _ -> :error
		end

		serialize &to_string/1
	end

	@desc "The custom scalar type for emails"
	scalar :email do
		parse fn email ->
			case String.split(email, "@") do
				[username, domain] -> {username, domain}

				_ -> throw "Email \"#{email}\" is not valid."
			end
		end

		serialize fn {username, domain} ->
			"#{username}@#{domain}"
		end
	end

	@desc "The custom scalar type for dates in format \"yyyy-mm-dd\""
	scalar :date do
		parse fn input ->
			with %Absinthe.Blueprint.Input.String{value: value} <- input,
			{:ok, date} <- Date.from_iso8601(value) do
				{:ok, date}
			else
				_ -> :error
			end
		end

		serialize fn date ->
			Date.to_iso8601(date)
		end
	end
end
