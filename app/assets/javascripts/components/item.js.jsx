var Item = React.createClass({

  render: function() {
    return(
      <ul className="list-unstyled">
        <li>
          <span>To: </span>
          {this.props.data.to}
          </li>
        <li>
          <span>Subject: </span>
          {this.props.data.subject}
        </li>
      </ul>
    );
  }
});