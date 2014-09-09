# EasyFilter

By [Peter Kepes](https://github.com/kepes).

Filter and sort ActiveRecord model for Rails app with [Bootstrap](http://getbootstrap.com/) view helpers.

## Installation

Add this line to your application's Gemfile:

    gem 'easy_filter', git: 'https://github.com/kepes/easy-filter.git'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install easy_filter

## Usage

Gem provide an AciveRecord model addition and a view helper.

### Controller

    Model.easy_filter(params)

EasyFilter works on ActiveRecord::Relation. You can chain with any other module like [Kaminari paginator](https://github.com/amatsuda/kaminari) or [cancan](https://github.com/ryanb/cancan).

    @model = @model.includes(:other_model).easy_filter(params).page params[:page]

### View

    <%= easy_filter ModelClass, [:name, :expiry_date] %>

`easy_filter` view helper will generate a search form for `ModelClass` with field `name` and `expiry_date`. EasyFilter try to determine the correct filed type from type of specified column. For text fields it will generate a normal text field and for date field it will generate a `JQuery::DatePicker`.

You can define an `Array` of `Hash` and EasyFilter will generate a dropdown automaticly.

Code in model or controller:

```ruby
def self.statuses
  [
    { code: 'A', name: 'Status A', color: :default},
    { code: 'B', name: 'Status B', color: :info},
    { code: 'C', name: 'Status C', color: :warning},
  ]
end
```

In view:
    <%= easy_filter ModelClass, [:name, :expiry_date, [:status, ModelClass.statuses]] %>

#### Advanced parameters

`easy_filter` model addition provide paramters to define HTML input field names for processing.

    def easy_filter(params, prefixes = { main: 'filter_', from: 'from_', to: 'to_', exact: 'exact_', sort: 'sort', direction: 'direction' })

If you change prefix parameters dont't forget to change it for view helpers too!

#### Define sorting

For sorting you can use `easy_sort` view helper.

    <%= easy_sort :id, t('activerecord.attributes.model.id') %>

#### Override view templates

Default view helper templates generates [Bootstrap](http://getbootstrap.com/) components. If you want to use your own templates or just modify templates you should create an `app/views/easy_filter` folder in your app and create the corresponding view file. Available view files:

    app/views/easy_filter/_buttons.html.erb
    app/views/easy_filter/_field_datetime.html.erb
    app/views/easy_filter/_form_close.html.erb
    app/views/easy_filter/_form_field_open.html.erb
    app/views/easy_filter/_sort_field.html.erb
    app/views/easy_filter/_field_array.html.erb
    app/views/easy_filter/_field_text.html.erb
    app/views/easy_filter/_form_field_close.html.erb
    app/views/easy_filter/_form_open.html.erb

#### Advanced parameters

View helpers provide paramters to define HTML input field names.

    def easy_filter(model_class, filters, prefixes = { main: 'filter_', from: 'from_', to: 'to_', exact: 'exact_' })

    def easy_sort(column, title = nil, sort = 'sort', direction = 'direction')

All default templates will use specified prefixes for input fields. If you have to use different names just use this parameters to redefine it.

If you change prefix parameters dont't forget to change it for model addition too!

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
