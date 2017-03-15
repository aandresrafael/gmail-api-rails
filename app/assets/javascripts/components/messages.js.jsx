var Messages = React.createClass({
  getInitialState: function() {
    return {
      messages: []
    }
  },

  renderMessage: function(message) {
    return <Message message={message} key={message.from}/>;
  },

  render: function() {
    return (
      <div>
        <div>{this.props.data.messages.map(this.renderMessage)}</div>
      </div>
    );
  }
});