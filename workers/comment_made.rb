require_relative "../app"

begin
  Ost[:comment_made].each do |json|
    hash = JSON.load(json)

    email = hash["email"]
    name = hash["name"]
    comment_by = hash["comment_by"]
    ballot_title = hash["ballot_title"]

    text = Mailer.render("comment_made", {
      name: name,
      comment_by: comment_by,
      ballot_title: ballot_title })

    Malone.deliver(
      from: "info@teamballots.com",
      to: email,
      subject: "[Team Ballots] #{comment_by} added a comment on a ballot",
      text: text)
  end
rescue Net::SMTPAuthenticationError
  Ost[:comment_made_failures_log].push(sprintf("MALONE_URL: %s, json: %s", MALONE_URL.inspect, json))
end
