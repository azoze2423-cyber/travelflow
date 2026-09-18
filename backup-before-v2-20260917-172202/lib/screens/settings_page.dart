import 'package:flutter/material.dart';
import '../store/app_store.dart';
import '../widgets/common.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.store});
  final AppStore store;
  @override State<SettingsPage> createState()=>_SettingsPageState();
}
class _SettingsPageState extends State<SettingsPage>{
  late TextEditingController name,currency,email,password,phone,address,userName;
  @override void initState(){super.initState();final s=widget.store;name=TextEditingController(text:s.agencyName);currency=TextEditingController(text:s.currency);email=TextEditingController(text:s.currentUserEmail);password=TextEditingController();phone=TextEditingController(text:s.phone);address=TextEditingController(text:s.address);userName=TextEditingController(text:s.currentUserName);}
  Future<void> _save() async {try{await widget.store.updateSettings(name:name.text.trim(),curr:currency.text.trim().isEmpty?'AED':currency.text.trim().toUpperCase(),email:email.text.trim(),password:password.text,agencyPhone:phone.text.trim(),agencyAddress:address.text.trim(),userName:userName.text.trim());if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Settings saved on server')));}catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('$e')));}}
  @override Widget build(BuildContext context)=>SingleChildScrollView(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    const PageHeader(title:'Settings',subtitle:'Agency and signed-in account settings'),const SizedBox(height:20),
    if(widget.store.isAdmin) Container(width:double.infinity,padding:const EdgeInsets.all(22),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(18),border:Border.all(color:const Color(0xFFE5E7EB))),child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:760),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Text('Agency',style:TextStyle(fontSize:18,fontWeight:FontWeight.w800)),const SizedBox(height:14),TextField(controller:name,decoration:const InputDecoration(labelText:'Agency name')),const SizedBox(height:12),Row(children:[Expanded(child:TextField(controller:currency,decoration:const InputDecoration(labelText:'Currency'))),const SizedBox(width:12),Expanded(child:TextField(controller:phone,decoration:const InputDecoration(labelText:'Agency phone')))]),const SizedBox(height:12),TextField(controller:address,decoration:const InputDecoration(labelText:'Address')),
    ]))),
    if(widget.store.isAdmin) const SizedBox(height:18),
    Container(width:double.infinity,padding:const EdgeInsets.all(22),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(18),border:Border.all(color:const Color(0xFFE5E7EB))),child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:760),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text('My account • ${widget.store.currentUserRole}',style:const TextStyle(fontSize:18,fontWeight:FontWeight.w800)),const SizedBox(height:14),TextField(controller:userName,decoration:const InputDecoration(labelText:'Name')),const SizedBox(height:12),TextField(controller:email,decoration:const InputDecoration(labelText:'Email')),const SizedBox(height:12),TextField(controller:password,obscureText:true,decoration:const InputDecoration(labelText:'New password',helperText:'Leave blank to keep current password')),const SizedBox(height:18),Align(alignment:Alignment.centerLeft,child:FilledButton.icon(onPressed:_save,icon:const Icon(Icons.save_outlined),label:const Text('Save settings'))),
    ]))),const SizedBox(height:16),Text('Server: ${widget.store.serverUrl}',style:TextStyle(color:Colors.grey.shade600,fontSize:12)),
  ]));
}
