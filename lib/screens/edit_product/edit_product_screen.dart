import 'package:flutter/material.dart';
import 'package:loja_virtual/models/product.dart';
import 'package:loja_virtual/screens/edit_product/components/images_form.dart';
import 'package:loja_virtual/screens/edit_product/components/sizes_form.dart';
import 'package:loja_virtual/models/product_manager.dart';
import 'package:provider/provider.dart';

class EditProductScreen extends StatelessWidget { //tela para editar produto

  EditProductScreen(Product p) : //se p for null cria um novo produto. necessario pq esta tela pode vim do pedido de editar produto ou criar
                                  //um novo
        editing = p != null, //se o produto for null é pq esta criando
        product = p != null ? p.clone() : Product(); //cria um clone para nao precisar editar o origina

  final GlobalKey<FormState> formKey = GlobalKey<FormState>(); //para validar os campos do form
  final Product product;
  final bool editing;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return ChangeNotifierProvider.value(
      value: product,
      child: Scaffold(
        appBar: AppBar(
          title: Text(editing ? 'Editar Produto' : 'Criar Produto'), //checa se esta editando ou criando anuncio
          centerTitle: true,
        ),
        backgroundColor: Colors.white,
        body: Form(
          key: formKey,
          child: ListView(
            children: <Widget>[
              ImagesForm(product), //formulrio customizado para mostrar as imagens do produto
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch, //para o widget ocupar o tamanho maximo da coluna
                  children: <Widget>[
                    TextFormField( //titulo
                      initialValue: product.name,
                      decoration: const InputDecoration(
                        hintText: 'Título',
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600
                      ),
                      validator: (name){
                        if(name.length < 6)
                          return 'Título muito curto';
                        return null;
                      },
                      onSaved: (name) => product.name = name,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'A partir de',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Text( //preço
                      'R\$ ...',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    Padding( //descrição
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        'Descrição',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    TextFormField(
                      initialValue: product.description,
                      style: const TextStyle(
                          fontSize: 16
                      ),
                      decoration: const InputDecoration(
                          hintText: 'Descrição',
                          border: InputBorder.none
                      ),
                      maxLines: null,
                      validator: (desc){
                        if(desc.length < 10)
                          return 'Descrição muito curta';
                        return null; //qdo é nulo é pq está tudo ok...
                      },
                      onSaved: (desc) => product.description = desc,
                    ),
                    SizesForm(product), //formulario customizado para mostrar os tamanhos
                    const SizedBox(height: 20,), //espaço para separar o formulario do boto salvar
                   Consumer<Product>(
                       builder: (_,product,__){
                         return  SizedBox(
                           height: 44,
                           child: RaisedButton(
                             onPressed: !product.loading ? () async { //se o produto estiver carregando
                               if(formKey.currentState.validate()){
                                 formKey.currentState.save(); //chama o metodo save em cada um dos itens do form depois de verificar que todos são validos
                                 await product.save();
                                 context.read<ProductManager>() //para avisar q o produto foi alterado
                                     .update(product);
                                 Navigator.of(context).pop();
                               }
                             } : null, //desabilita o botão se estiver carregando
                             textColor: Colors.white,
                             color: primaryColor,
                             disabledColor: primaryColor.withAlpha(100),
                             child: product.loading ? CircularProgressIndicator( //aparece um circulo carregando enquanto upload está sendo feito
                               valueColor: AlwaysStoppedAnimation(Colors.white),
                             ): const Text(
                               'Salvar', //aparece texto qdo para de carregar
                               style: TextStyle(fontSize: 18.0),
                             ),
                           ),
                         );
                       }
                   )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
