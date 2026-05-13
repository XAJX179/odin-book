let totalSize = 0
const maxTotalSize = 300 * 1024
let errors = ""

window.addEventListener("trix-file-accept", function (event) {
  let file = event.file

  const acceptedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp']
  if (!acceptedTypes.includes(event.file.type)) {
    event.preventDefault()
    errors += "Only images are allowed, in the following formats: [png,jpeg,gif,webp]. For videos you can link a youtube video!\n"
  }
  const maxFileSize = 300 * 1024
  if (file.size > maxFileSize) {
    event.preventDefault()
    errors += "Image is too large. only image less than 300kb allowed. compress it or share a link!\n"
  }

  const editor = event.target

  editor.editor.getDocument().getAttachments().forEach((attachment) => {
    if (attachment.id) {
      console.log(attachment)
      totalSize += attachment.attributes.values.filesize
    }
  })

  totalSize += file.size


  if (totalSize > maxTotalSize) {
    event.preventDefault()
    errors += "Total image size must not exceed 300KB (combined limit).\n"
  }

  console.log("New total:", totalSize)

  if (errors.length > 0) {
    alert(errors)
    errors = ""
  }

  totalSize = 0
})
