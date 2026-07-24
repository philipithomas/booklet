json.extract! member, :id, :name

json.sgid member.attachable_sgid
json.content render(partial: "communities/members/mention", locals: { member: member }, formats: [ :html ])
