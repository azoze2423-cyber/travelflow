import 'package:flutter/material.dart';
import '../store/app_store.dart';
import 'bookings_page.dart';
import 'customers_page.dart';
import 'dashboard_page.dart';
import 'payments_page.dart';
import 'online_requests_page.dart';
import 'invoices_page.dart';
import 'reports_page.dart';
import 'settings_page.dart';
import 'suppliers_page.dart';
import 'visas_page.dart';
import 'users_page.dart';
import 'customer_portal_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.store});
  final AppStore store;
  @override State<HomeShell> createState()=>_HomeShellState();
}
class _NavItem { const _NavItem(this.label,this.icon,this.page); final String label;final IconData icon;final Widget page; }
class _HomeShellState extends State<HomeShell>{
  int index=0;
  List<_NavItem> get items=>[
    _NavItem('Dashboard',Icons.dashboard_outlined,DashboardPage(store:widget.store)),
    _NavItem('Customers',Icons.people_outline,CustomersPage(store:widget.store)),
    _NavItem('Bookings',Icons.luggage_outlined,BookingsPage(store:widget.store)),
    _NavItem('Online Requests',Icons.public_outlined,OnlineRequestsPage(store:widget.store)),
    _NavItem('Payments',Icons.payments_outlined,PaymentsPage(store:widget.store)),
    _NavItem('Invoices',Icons.receipt_long_outlined,InvoicesPage(store:widget.store)),
    _NavItem('Visas',Icons.description_outlined,VisasPage(store:widget.store)),
    _NavItem('Suppliers',Icons.business_outlined,SuppliersPage(store:widget.store)),
    _NavItem('Reports',Icons.bar_chart_outlined,ReportsPage(store:widget.store)),
    if(widget.store.isAdmin)_NavItem('Team',Icons.manage_accounts_outlined,UsersPage(store:widget.store)),
    _NavItem('Settings',Icons.settings_outlined,SettingsPage(store:widget.store)),
  ];
  @override Widget build(BuildContext context)=>AnimatedBuilder(animation:widget.store,builder:(context,_){final nav=items;if(index>=nav.length)index=0;final wide=MediaQuery.of(context).size.width>=980;return Scaffold(appBar:wide?null:AppBar(title:Text(widget.store.agencyName),actions:[IconButton(onPressed:()=>widget.store.refresh(),icon:const Icon(Icons.refresh)),IconButton(onPressed:_logout,icon:const Icon(Icons.logout))]),drawer:wide?null:Drawer(child:SafeArea(child:_menu(true,nav))),body:Row(children:[if(wide)SizedBox(width:250,child:_menu(false,nav)),Expanded(child:SafeArea(child:Padding(padding:const EdgeInsets.all(24),child:nav[index].page)))]));});
  Widget _menu(bool drawer,List<_NavItem> nav)=>Material(color:const Color(0xFF071C33),child:Column(children:[Padding(padding:const EdgeInsets.all(22),child:Row(children:[Container(width:42,height:42,decoration:BoxDecoration(gradient:const LinearGradient(colors:[Color(0xFF2DD4BF),Color(0xFF3B82F6)]),borderRadius:BorderRadius.circular(13)),child:const Icon(Icons.flight_takeoff,color:Colors.white)),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(widget.store.agencyName,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(color:Colors.white,fontWeight:FontWeight.w800)),Text('${widget.store.currentUserName} • ${widget.store.currentUserRole}',maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(color:Colors.white54,fontSize:11))]))])),const Divider(color:Color(0xFF374151),height:1),const SizedBox(height:10),Expanded(child:ListView.builder(itemCount:nav.length,itemBuilder:(context,i)=>Padding(padding:const EdgeInsets.symmetric(horizontal:10,vertical:2),child:ListTile(selected:index==i,selectedTileColor:const Color(0xFF0F5A72),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(12)),leading:Icon(nav[i].icon,color:index==i?Colors.white:Colors.white70),title:Text(nav[i].label,style:TextStyle(color:index==i?Colors.white:Colors.white70,fontWeight:index==i?FontWeight.w700:FontWeight.w500)),onTap:(){setState(()=>index=i);if(drawer)Navigator.pop(context);})))),Padding(padding:const EdgeInsets.all(12),child:ListTile(leading:const Icon(Icons.logout,color:Colors.white70),title:const Text('Logout',style:TextStyle(color:Colors.white70)),onTap:_logout))]));
  Future<void> _logout()async{await widget.store.logout();if(mounted)Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder:(_)=>CustomerPortalScreen(store:widget.store)),(_)=>false);}
}
