var Message = React.createClass({

  renderItem: function(item) {
    return <Item item={item} key={item.from}/>;
  },

  render: function() {
    var index = 0;
    var createItem = function(item) {
      index += 1;
      var props = {
        data: item,
        key: index
      };

        return <Item {...props} />;
      }.bind(this);

    return (
      <div>
        <h4 className="page-header">{this.props.message.from}</h4>
        <div className="group">
          {this.props.message.items.map(createItem)}
        </div>
      </div>
    );
  }
});