<?php

namespace App\DataFixtures;

use App\Entity\Book as BookEntity;
use Doctrine\Bundle\FixturesBundle\Fixture;
use Doctrine\Persistence\ObjectManager;
use Gedmo\Translatable\Entity\Translation;

class Book extends Fixture
{
    public function load(ObjectManager $manager)
    {
        $repository = $manager->getRepository(Translation::class);

        for ($i = 0; $i < 20; $i++) {
            $book = new BookEntity();
            $book->setName('Book '.$i);
            $book->addAuthor($this->getReference(Author::AUTHOR_REFERENCE . '_' . $i));
            $repository->translate($book, 'name', 'ru', 'Книга '.$i);
            $manager->persist($book);
        }
        $manager->flush();
    }

    public function getDependencies()
    {
        return array(
            Author::class,
        );
    }
}
