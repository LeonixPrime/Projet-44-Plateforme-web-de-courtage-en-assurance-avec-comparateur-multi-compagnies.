document.querySelectorAll('form[data-confirm]').forEach(form=>form.addEventListener('submit',e=>{if(!confirm(form.dataset.confirm))e.preventDefault()}));
const type=document.querySelector('#typeClient');
function toggleClientFields(){if(!type)return;const company=type.value==='entreprise';document.querySelectorAll('.enterprise-field').forEach(el=>el.classList.toggle('d-none',!company));document.querySelectorAll('.person-field').forEach(el=>el.classList.toggle('d-none',company));}
if(type){type.addEventListener('change',toggleClientFields);toggleClientFields();}
document.querySelectorAll('.needs-validation').forEach(form=>form.addEventListener('submit',event=>{if(!form.checkValidity()){event.preventDefault();event.stopPropagation()}form.classList.add('was-validated')}));

