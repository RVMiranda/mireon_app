import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'view_models/media_gallery_notifier.dart';
import 'widgets/media_gallery_view.dart';
import 'view_models/media_selection_notifier.dart';
import 'widgets/selection_action_bar.dart';
import 'widgets/media_search_delegate.dart';
import '../domain/entities/media_filter.dart';
import '../../profiles/presentation/widgets/profile_switcher.dart';

class LibraryScreen extends ConsumerStatefulWidget { const LibraryScreen({super.key}); @override ConsumerState<LibraryScreen> createState()=>_LibraryScreenState(); }
class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  MediaFilter filter = MediaFilter.all;
  @override Widget build(BuildContext context) {
    final selection = ref.watch(selectionNotifierProvider); final notifier=ref.read(selectionNotifierProvider.notifier); final state=ref.watch(mediaGalleryProvider(filter));
    return Scaffold(appBar: AppBar(title: PopupMenuButton<MediaFilter>(tooltip:'Cambiar vista', onSelected:(v)=>setState(()=>filter=v), itemBuilder:(_)=>const [PopupMenuItem(value:MediaFilter.all,child:Text('Todo')),PopupMenuItem(value:MediaFilter.photos,child:Text('Fotos')),PopupMenuItem(value:MediaFilter.videos,child:Text('Vídeos'))], child: Row(mainAxisSize:MainAxisSize.min,children:[Text(_label),const Icon(Icons.keyboard_arrow_down)])), actions:[if(!selection.isSelectionMode) IconButton(icon:const Icon(Icons.search),tooltip:'Buscar',onPressed:()=>showSearch(context:context,delegate:MediaSearchDelegate(ref:ref,filter:filter))),if(!selection.isSelectionMode) const ProfileSwitcher(),if(selection.isSelectionMode) IconButton(icon:const Icon(Icons.select_all),onPressed:()=>notifier.selectAll(state.items.map((e)=>e.id).toList())),if(!selection.isSelectionMode) TextButton(onPressed:notifier.enterSelectionMode,child:const Text('Seleccionar'))]), body:Stack(children:[MediaGalleryView(filter:filter),Align(alignment:Alignment.bottomCenter,child:SelectionActionBar(onClearSelection:notifier.exitSelectionMode))]));
  }
  String get _label => switch(filter){MediaFilter.all=>'Biblioteca',MediaFilter.photos=>'Fotos',MediaFilter.videos=>'Vídeos'};
}
